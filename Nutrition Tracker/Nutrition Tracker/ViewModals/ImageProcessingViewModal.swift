import Foundation
import SwiftUI
import UIKit

@MainActor
class ImageProcessingViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isShowingCamera = false
    @Published var error: Error?
    
    enum ProcessingType {
        case nutritionLabel
        case waterBottle
    }
    
    func processImage(for type: ProcessingType, userId: String) async {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.8) else { return }
        
        do {
            switch type {
            case .nutritionLabel:
                _ = try await NetworkManager.shared.processNutritionLabel(image: imageData, userId: userId)
            case .waterBottle:
                _ = try await NetworkManager.shared.processWaterBottle(image: imageData, userId: userId)
            }
        } catch {
            self.error = error
        }
    }
    
    func clearError() {
        error = nil
    }
}
