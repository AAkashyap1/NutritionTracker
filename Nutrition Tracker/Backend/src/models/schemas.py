from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class Gender(str, Enum):
    MALE = "male"
    FEMALE = "female"


class ActivityLevel(str, Enum):
    SEDENTARY = "sedentary"
    LIGHT = "light"
    MODERATE = "moderate"
    VERY = "very"
    EXTRA = "extra"


class UserProfile(BaseModel):
    user_id: str
    age: int = Field(..., ge=0, le=120)
    weight: float = Field(..., ge=20, le=500)
    height: float = Field(..., ge=50, le=300)
    goalWeight: float = Field(..., ge=20, le=500)
    activityLevel: ActivityLevel
    gender: Gender


class NutritionData(BaseModel):
    calories: float = Field(..., ge=0)
    protein: float = Field(..., ge=0)
    carbs: float = Field(..., ge=0)
    fats: float = Field(..., ge=0)
    fiber: float = Field(..., ge=0)


class WaterData(BaseModel):
    amount: float = Field(..., ge=0)


class DailyProgress(BaseModel):
    calories: float = Field(default=0, ge=0)
    protein: float = Field(default=0, ge=0)
    carbs: float = Field(default=0, ge=0)
    fats: float = Field(default=0, ge=0)
    fiber: float = Field(default=0, ge=0)
    water: float = Field(default=0, ge=0)
