class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:8000"  // Update with your actual URL
    
    // MARK: - Image Processing Endpoints
    
    func processNutritionLabel(image: Data, userId: String) async throws -> NutritionData {
        let url = "\(baseURL)/process_nutrition_label"
        
        // Create multipart form data
        var request = URLRequest(url: URL(string: url)!)
        let boundary = UUID().uuidString
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        // Add image part
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(image)
        body.append("\r\n")
        // Add user_id part
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
        // Similar to processNutritionLabel but with /process_water_bottle endpoint
    }
    
    // MARK: - User Profile and Progress Endpoints
    
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
} 