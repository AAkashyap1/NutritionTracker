import SwiftUI
import UIKit

@MainActor
class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isShowingCamera = false
    @Published var isProcessing = false
    @Published var error: AppError?
    
    func processImage(for type: ImageProcessingType, userId: String) async {
        guard let image = selectedImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            error = .imageProcessingError("Invalid image data")
            return
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            switch type {
            case .nutritionLabel:
                let nutritionData = try await NetworkManager.shared.processNutritionLabel(image: imageData, userId: userId)
                // The backend will automatically update daily progress
                
            case .waterBottle:
                let waterData = try await NetworkManager.shared.processWaterBottle(image: imageData, userId: userId)
                // The backend will automatically update daily progress
            }
            
            selectedImage = nil
            
        } catch {
            self.error = error as? AppError ?? .unknown
        }
    }
    
    func clearError() {
        error = nil
    }
}

enum ImageProcessingType {
    case nutritionLabel
    case waterBottle
} 