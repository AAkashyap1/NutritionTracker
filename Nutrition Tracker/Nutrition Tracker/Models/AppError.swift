enum AppError: Error, LocalizedError {
    case networkError(String)
    case authenticationError(String)
    case imageProcessingError(String)
    case serverError(String)
    case decodingError(String)
    case invalidInput(String)
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message): return "Network Error: \(message)"
        case .authenticationError(let message): return "Authentication Error: \(message)"
        case .imageProcessingError(let message): return "Image Processing Error: \(message)"
        case .serverError(let message): return "Server Error: \(message)"
        case .decodingError(let message): return "Data Error: \(message)"
        case .invalidInput(let message): return "Invalid Input: \(message)"
        case .unauthorized: return "Unauthorized Access"
        case .unknown: return "An unknown error occurred"
        }
    }
} 