from ..models.schemas import User, ActivityLevel, Gender, NutritionGoals
from typing import Dict


def calculate_daily_targets(user: User) -> NutritionGoals:
    """Calculate daily nutrition targets based on user profile."""

    activity_multipliers = {
        "sedentary": 1.2,
        "light": 1.375,
        "moderate": 1.55,
        "very": 1.725,
        "extra": 1.9
    }

    try:
        weight = float(user.weight)
        height = float(user.height)
        age = int(user.age)
        activity_level = str(user.activityLevel).lower()
        gender = str(user.gender).lower()

        if gender == "male":
            bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5
        else:
            bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161

        activity_multiplier = activity_multipliers.get(activity_level, 1.2)

        daily_calories = bmr * activity_multiplier

        protein_target = weight * 2.2
        fat_target = (daily_calories * 0.30) / 9
        carbs_target = (daily_calories * 0.40) / \
            4
        fiber_target = 30.0
        water_target = weight * 0.033

        return NutritionGoals(
            dailyCalories=round(daily_calories, 2),
            protein=round(protein_target, 2),
            carbs=round(carbs_target, 2),
            fats=round(fat_target, 2),
            fiber=round(fiber_target, 2),
            water=round(water_target, 2)
        )
    except Exception as e:
        print(f"Error in calculations: {str(e)}")
        raise Exception(f"Error calculating nutrition targets: {str(e)}")
