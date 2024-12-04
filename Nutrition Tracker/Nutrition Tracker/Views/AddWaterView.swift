import Foundation
import SwiftUI
import PhotosUI

struct AddWaterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var imageProcessingViewModel = ImageProcessingViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 300)
                    
                    if let image = imageProcessingViewModel.selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    } else {
                        VStack(spacing: 15) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            Text("Select a photo of your water bottle")
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Instructions")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        InstructionRow(number: "1", text: "Place your water bottle on a flat surface")
                        InstructionRow(number: "2", text: "Ensure good lighting")
                        InstructionRow(number: "3", text: "Center the bottle in frame")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 2)
                }
                .padding(.horizontal)
                
                Button(action: {
                    imageProcessingViewModel.isShowingCamera = true
                }) {
                    Label("Select Photo", systemImage: "photo.on.rectangle")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Add Water")
            .sheet(isPresented: $imageProcessingViewModel.isShowingCamera) {
                ImagePicker(selectedImage: $imageProcessingViewModel.selectedImage)
                    .onDisappear {
                        Task {
                            if let userId = userViewModel.currentUser?.id {
                                await imageProcessingViewModel.processImage(for: .waterBottle, userId: userId)
                                await userViewModel.refreshDailyProgress()
                                DispatchQueue.main.async {
                                    dismiss()
                                }
                            }
                        }
                    }
            }
        }
    }
}

struct AddWaterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddWaterView()
        }
    }
}
