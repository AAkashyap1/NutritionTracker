from ..models.schemas import UserProfile, ActivityLevel, Gender
from typing import Dict


def calculate_daily_targets(profile: UserProfile) -> Dict[str, float]:
    """Calculate daily nutrition targets based on user profile."""

    activity_multipliers = {
        ActivityLevel.SEDENTARY: 1.2,
        ActivityLevel.LIGHT: 1.375,
        ActivityLevel.MODERATE: 1.55,
        ActivityLevel.VERY: 1.725,
        ActivityLevel.EXTRA: 1.9
    }

    if profile.gender == Gender.MALE:
        bmr = (10 * profile.weight) + \
            (6.25 * profile.height) - (5 * profile.age) + 5
    else:
        bmr = (10 * profile.weight) + \
            (6.25 * profile.height) - (5 * profile.age) - 161

    daily_calories = bmr * activity_multipliers[profile.activityLevel]

    protein_target = profile.weight * 2.2
    fat_target = (daily_calories * 0.30) / 9
    carbs_target = (daily_calories * 0.40) / 4
    fiber_target = 30
    water_target = profile.weight * 0.033

    return {
        "dailyCalories": round(daily_calories, 2),
        "protein": round(protein_target, 2),
        "fats": round(fat_target, 2),
        "carbs": round(carbs_target, 2),
        "fiber": round(fiber_target, 2),
        "water": round(water_target, 2)
    }
