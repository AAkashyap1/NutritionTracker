from typing import Dict
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from .models.schemas import (
    User,
    NutritionData,
    WaterData,
    DailyProgress,
    NutritionGoals,
    UserCreateRequest,
    UserResponse
)
from .image_processor.nutrition_label import NutritionLabelProcessor
from .image_processor.water_bottle import WaterBottleProcessor
from .utils.calculations import calculate_daily_targets
from .firebase_manager import FirebaseManager
import os
from dotenv import load_dotenv
import uvicorn
from firebase_admin import auth

load_dotenv()

app = FastAPI()

nutrition_processor = NutritionLabelProcessor()
water_processor = WaterBottleProcessor()
firebase_manager = FirebaseManager('src/config/firebase_config.json')

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.post("/process_nutrition_label")
async def process_label(image: UploadFile = File(...), user_id: str = Form(...)) -> NutritionData:
    try:
        contents = await image.read()
        nutrition_data = nutrition_processor.process_image(contents)

        await firebase_manager.update_daily_progress(user_id, nutrition_data.dict())

        return nutrition_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/process_water_bottle")
async def process_water(image: UploadFile = File(...), user_id: str = Form(...)) -> WaterData:
    try:
        contents = await image.read()
        water_data = water_processor.process_image(contents)

        await firebase_manager.update_daily_progress(user_id, {"water": water_data.amount})

        return water_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/calculate_targets")
async def calculate_targets(user: User) -> NutritionGoals:
    try:
        print(f"Calculating targets for user: {user.dict()}")
        goals = calculate_daily_targets(user)
        print(f"Calculated goals: {goals}")
        return goals
    except Exception as e:
        print(f"Error calculating targets: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/daily_progress/{user_id}")
async def get_daily_progress(user_id: str) -> DailyProgress:
    progress = await firebase_manager.get_daily_progress(user_id)
    if not progress:
        return DailyProgress()
    return DailyProgress(**progress)


@app.post("/daily_progress/{user_id}")
async def update_daily_progress(user_id: str, progress: DailyProgress):
    success = await firebase_manager.update_daily_progress(user_id, progress.dict())
    if not success:
        raise HTTPException(
            status_code=400, detail="Failed to update progress")
    return {"status": "success"}


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc)}
    )


@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    return JSONResponse(
        status_code=500,
        content={"detail": str(exc)}
    )


@app.post("/signin")
async def signin(credentials: dict):
    try:
        email = credentials.get('email')
        password = credentials.get('password')
        user = await firebase_manager.sign_in_user(email, password)
        return user
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/create_user", response_model=UserResponse)
async def create_user(user_data: UserCreateRequest):
    try:
        print(f"1. Received user data: {user_data.dict()}")

        try:
            user = auth.create_user(
                email=user_data.email,
                password=user_data.password
            )
            print(f"2. Created Firebase Auth user: {user.uid}")

            profile_data = user_data.dict(exclude={'password'})
            profile_data['id'] = user.uid
            print(f"3. Prepared profile data: {profile_data}")

            result = await firebase_manager.create_user_profile(user.uid, profile_data)
            print(f"4. Stored user profile: {result}")

            return UserResponse(**result)

        except auth.EmailAlreadyExistsError:
            raise HTTPException(
                status_code=400,
                detail="Email already registered"
            )
        except Exception as auth_error:
            print(f"Auth Error: {str(auth_error)}")
            raise HTTPException(
                status_code=400,
                detail=f"Authentication Error: {str(auth_error)}"
            )

    except HTTPException as he:
        raise he
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail=f"Server Error: {str(e)}"
        )


@app.get("/user/{user_id}")
async def get_user(user_id: str) -> User:
    try:
        user_data = await firebase_manager.get_user(user_id)
        if not user_data:
            raise HTTPException(status_code=404, detail="User not found")
        return User(**user_data)
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
