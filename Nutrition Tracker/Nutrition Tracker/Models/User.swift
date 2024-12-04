struct User: Codable, Identifiable {
    let id: String
    let email: String
    var name: String
    var age: Int
    var weight: Double
    var height: Double
    var goalWeight: Double
    var activityLevel: ActivityLevel
    var gender: Gender
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email, name, age, weight, height, goalWeight
        case activityLevel = "activity_level"
        case gender
        case createdAt = "created_at"
    }
}

enum ActivityLevel: String, Codable {
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case very = "very"
    case extra = "extra"
}

enum Gender: String, Codable {
    case male = "male"
    case female = "female"
} 