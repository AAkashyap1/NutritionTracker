import Foundation
import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    @StateObject private var formData = CreateAccountFormData()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Full Name", text: $formData.name)
                    TextField("Age", text: $formData.age)
                        .keyboardType(.numberPad)
                    TextField("Weight (kg)", text: $formData.weight)
                        .keyboardType(.decimalPad)
                    TextField("Height (cm)", text: $formData.height)
                        .keyboardType(.decimalPad)
                    TextField("Goal Weight (kg)", text: $formData.goalWeight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Account Details")) {
                    TextField("Email", text: $formData.email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $formData.password)
                    SecureField("Confirm Password", text: $formData.confirmPassword)
                }
                
                Section(header: Text("Additional Information")) {
                    Picker("Gender", selection: $formData.gender) {
                        Text("Male").tag(Gender.male)
                        Text("Female").tag(Gender.female)
                    }
                    
                    Picker("Activity Level", selection: $formData.activityLevel) {
                        Text("Sedentary").tag(ActivityLevel.sedentary)
                        Text("Light").tag(ActivityLevel.light)
                        Text("Moderate").tag(ActivityLevel.moderate)
                        Text("Very Active").tag(ActivityLevel.very)
                        Text("Extra Active").tag(ActivityLevel.extra)
                    }
                }
                
                Section {
                    Button(action: createAccount) {
                        Text("Create Account")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .disabled(!formData.isValid || userViewModel.isLoading)
                    .listRowBackground(Color.green)
                }
            }
            .navigationTitle("Create Account")
            .navigationBarItems(leading: Button("Cancel") { dismiss() })
            .overlay(
                Group {
                    if userViewModel.isLoading {
                        ProgressView()
                            .background(Color.black.opacity(0.2))
                    }
                }
            )
        }
    }
    
    private func createAccount() {
        Task {
            let profile = formData.createUserProfile()
            await userViewModel.createAccount(
                email: formData.email,
                password: formData.password,
                profile: profile
            )
            if userViewModel.error == nil {
                dismiss()
            }
        }
    }
}

class CreateAccountFormData: ObservableObject {
    @Published var name = ""
    @Published var age = ""
    @Published var weight = ""
    @Published var height = ""
    @Published var goalWeight = ""
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var gender = Gender.male
    @Published var activityLevel = ActivityLevel.moderate
    
    var isValid: Bool {
        !name.isEmpty &&
        !age.isEmpty &&
        !weight.isEmpty &&
        !height.isEmpty &&
        !goalWeight.isEmpty &&
        !email.isEmpty &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    func createUserProfile() -> User {
        User(
            id: "",  // Will be set by backend
            email: email,
            name: name,
            age: Int(age) ?? 0,
            weight: Double(weight) ?? 0,
            height: Double(height) ?? 0,
            goalWeight: Double(goalWeight) ?? 0,
            activityLevel: activityLevel,
            gender: gender,
            createdAt: Date()
        )
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
    }
}
