import Foundation  

struct User: Codable {
    let id: String
    let email: String
    let name: String
    let age: Int
    let weight: Double
    let height: Double
    let goalWeight: Double
    let activityLevel: ActivityLevel
    let gender: Gender
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
    case other = "other"
}
