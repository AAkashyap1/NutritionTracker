from pydantic import BaseModel, EmailStr, Field
from enum import Enum
from typing import Optional


class Gender(str, Enum):
    male = "male"
    female = "female"
    other = "other"


class ActivityLevel(str, Enum):
    sedentary = "sedentary"
    light = "light"
    moderate = "moderate"
    very = "very"
    extra = "extra"


class User(BaseModel):
    id: Optional[str] = None
    email: str
    name: str
    age: int
    weight: float
    height: float
    goalWeight: float
    activityLevel: str
    gender: str


class DailyProgress(BaseModel):
    calories: float = 0.0
    protein: float = 0.0
    carbs: float = 0.0
    fats: float = 0.0
    fiber: float = 0.0
    water: float = 0.0


class NutritionData(BaseModel):
    calories: float
    protein: float
    carbs: float
    fats: float
    fiber: float


class WaterData(BaseModel):
    amount: float


class NutritionGoals(BaseModel):
    dailyCalories: float = Field(..., ge=0)
    protein: float = Field(..., ge=0)
    carbs: float = Field(..., ge=0)
    fats: float = Field(..., ge=0)
    fiber: float = Field(..., ge=0)
    water: float = Field(..., ge=0)


class UserCreateRequest(BaseModel):
    email: str
    password: str
    name: str
    age: int
    weight: float
    height: float
    goalWeight: float
    activityLevel: str
    gender: str


class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    age: int
    weight: float
    height: float
    goalWeight: float
    activityLevel: str
    gender: str
