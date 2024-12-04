//
//  AddFoodScreen.swift
//  Nutrition Tracker
//
//  Created by Ananth Kashyap on 12/4/24.
//

import Foundation
import SwiftUI

struct AddFoodView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCamera = false
    @State private var showingInstructions = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if showingInstructions {
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
                }
                
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
                
                Button(action: { showCamera = true }) {
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
