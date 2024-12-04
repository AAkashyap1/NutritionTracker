import Foundation
import SwiftUI

struct AddFoodView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var imageProcessingViewModel = ImageProcessingViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                VStack(alignment: .leading, spacing: 20) {
                    Text("How to Scan Nutrition Labels")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        InstructionRow(number: "1", text: "Flatten the nutrition label")
                        InstructionRow(number: "2", text: "Ensure good lighting")
                        InstructionRow(number: "3", text: "Hold camera steady")
                        InstructionRow(number: "4", text: "Center the label in frame")
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .padding()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 350)
                    
                    VStack {
                        Image(systemName: "doc.viewfinder")
                            .font(.system(size: 40))
                            .foregroundColor(.green)
                        Text("Position nutrition label here")
                            .padding(.top)
                    }
                }
                .padding()
                
                Button(action: { imageProcessingViewModel.isShowingCamera = true }) {
                    Label("Scan Label", systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Add Food")
            .sheet(isPresented: $imageProcessingViewModel.isShowingCamera) {
                ImagePicker(selectedImage: $imageProcessingViewModel.selectedImage, sourceType: .camera)
                    .onDisappear {
                        Task {
                            if let userId = userViewModel.currentUser?.id {
                                await imageProcessingViewModel.processImage(for: .nutritionLabel, userId: userId)
                            }
                        }
                    }
            }
            .alert("Error", isPresented: .constant(imageProcessingViewModel.error != nil)) {
                Button("OK") { imageProcessingViewModel.clearError() }
            } message: {
                Text(imageProcessingViewModel.error?.localizedDescription ?? "")
            }
        }
    }
}

struct AddFoodView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddFoodView()
        }
    }
}
