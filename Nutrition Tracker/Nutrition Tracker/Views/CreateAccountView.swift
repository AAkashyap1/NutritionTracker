//
//  CreateAccountScreen.swift
//  Nutrition Tracker
//
//  Created by Ananth Kashyap on 12/4/24.
//

import Foundation
import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var goalWeight: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Image(systemName: "person.crop.circle.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Create Your Profile")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Let's get to know you better")
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 20) {
                        CustomTextField(icon: "person.fill", placeholder: "Full Name", text: $name)
                        CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                            .autocapitalization(.none)
                        CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                        CustomTextField(icon: "number", placeholder: "Age", text: $age)
                            .keyboardType(.numberPad)
                        CustomTextField(icon: "scalemass.fill", placeholder: "Current Weight (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                        CustomTextField(icon: "arrow.up.and.down", placeholder: "Height (cm)", text: $height)
                            .keyboardType(.decimalPad)
                        CustomTextField(icon: "target", placeholder: "Goal Weight (kg)", text: $goalWeight)
                            .keyboardType(.decimalPad)
                    }
                    .padding(.horizontal, 30)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Create Account")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                }
            }
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
