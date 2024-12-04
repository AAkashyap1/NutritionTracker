//
//  AddWaterView.swift
//  Nutrition Tracker
//
//  Created by Ananth Kashyap on 12/4/24.
//

import Foundation
import SwiftUI

struct AddWaterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCamera = false
    @State private var waterAmount: Double = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 300)
                    
                    VStack(spacing: 15) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 40))
                            .foregroundColor(.blue)
                        Text("Take a picture of your water bottle")
                            .multilineTextAlignment(.center)
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
                
                Button(action: { showCamera = true }) {
                    Label("Take Photo", systemImage: "camera")
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
