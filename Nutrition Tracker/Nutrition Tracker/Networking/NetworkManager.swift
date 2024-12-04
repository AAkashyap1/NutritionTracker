import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:8000"
    
    func processNutritionLabel(image: Data, userId: String) async throws -> NutritionData {
        let url = "\(baseURL)/process_nutrition_label"
        
        var request = URLRequest(url: URL(string: url)!)
        let boundary = UUID().uuidString
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(image)
        body.append("\r\n")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n")
        body.append(userId)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(NutritionData.self, from: data)
    }
    
    func processWaterBottle(image: Data, userId: String) async throws -> WaterData {
        let url = "\(baseURL)/process_water_bottle"
        
        var request = URLRequest(url: URL(string: url)!)
        let boundary = UUID().uuidString
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(image)
        body.append("\r\n")
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n")
        body.append(userId)
        body.append("\r\n")
        body.append("--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(WaterData.self, from: data)
    }
    
    func createUser(email: String, password: String, profile: User) async throws -> User {
        let url = "\(baseURL)/create_user"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData = [
            "email": email,
            "password": password,
            "name": profile.name,
            "age": profile.age,
            "weight": profile.weight,
            "height": profile.height,
            "goalWeight": profile.goalWeight,
            "activityLevel": profile.activityLevel.rawValue,
            "gender": profile.gender.rawValue
        ] as [String : Any]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(User.self, from: data)
    }
    
    func getDailyProgress(userId: String) async throws -> DailyProgress {
        let url = "\(baseURL)/daily_progress/\(userId)"
        let request = URLRequest(url: URL(string: url)!)
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(DailyProgress.self, from: data)
    }
    
    func updateDailyProgress(userId: String, progress: DailyProgress) async throws {
        let url = "\(baseURL)/daily_progress/\(userId)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(progress)
        
        let (_, _) = try await URLSession.shared.data(for: request)
    }
    
    func calculateTargets(profile: User) async throws -> NutritionGoals {
        let url = "\(baseURL)/calculate_targets"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(profile)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(NutritionGoals.self, from: data)
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let url = "\(baseURL)/signin"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let credentials = ["email": email, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: credentials)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(User.self, from: data)
    }

    func createAccount(email: String, password: String, profile: User) async throws -> User {
        let url = "\(baseURL)/create_user"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData: [String: Any] = [
            "email": email,
            "password": password,
            "name": profile.name,
            "age": profile.age,
            "weight": profile.weight,
            "height": profile.height,
            "goalWeight": profile.goalWeight,
            "activityLevel": profile.activityLevel.rawValue.lowercased(),
            "gender": profile.gender.rawValue.lowercased()
        ]
        
        print("Sending user data: \(userData)")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Error Response: \(errorString)")
                    throw AppError.serverError(errorString)
                }
            }
        }
        
        do {
            return try JSONDecoder().decode(User.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            if let responseString = String(data: data, encoding: .utf8) {
                print("Raw response: \(responseString)")
            }
            throw error
        }
    }
    
    func getUser(userId: String) async throws -> User {
        let url = "\(baseURL)/user/\(userId)"
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(User.self, from: data)
    }
}
