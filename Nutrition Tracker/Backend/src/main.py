from typing import Dict
from fastapi import FastAPI, File, UploadFile, HTTPException, Depends, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from .models.schemas import *
from .image_processor.nutrition_label import NutritionLabelProcessor
from .image_processor.water_bottle import WaterBottleProcessor
from .utils.calculations import calculate_daily_targets
from .firebase_manager import FirebaseManager
import os
from dotenv import load_dotenv
import uvicorn

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

        # Automatically update daily progress
        await firebase_manager.update_daily_progress(user_id, nutrition_data.dict())

        return nutrition_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/process_water_bottle")
async def process_water(image: UploadFile = File(...), user_id: str = Form(...)) -> WaterData:
    try:
        contents = await image.read()
        water_data = water_processor.process_image(contents)

        # Automatically update daily progress
        await firebase_manager.update_daily_progress(user_id, {"water": water_data.amount})

        return water_data
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/calculate_targets")
async def calculate_targets(profile: UserProfile) -> Dict[str, float]:
    try:
        return calculate_daily_targets(profile)
    except Exception as e:
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

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
