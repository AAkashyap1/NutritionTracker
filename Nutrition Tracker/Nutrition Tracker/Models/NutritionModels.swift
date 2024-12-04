struct NutritionData: Codable {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fats: Double
    var fiber: Double
}

struct WaterData: Codable {
    var amount: Double
}

struct DailyProgress: Codable {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fats: Double
    var fiber: Double
    var water: Double
    
    static var empty: DailyProgress {
        DailyProgress(calories: 0, protein: 0, carbs: 0, fats: 0, fiber: 0, water: 0)
    }
}

struct NutritionGoals: Codable {
    var dailyCalories: Double
    var protein: Double
    var carbs: Double
    var fats: Double
    var fiber: Double
    var water: Double
}
