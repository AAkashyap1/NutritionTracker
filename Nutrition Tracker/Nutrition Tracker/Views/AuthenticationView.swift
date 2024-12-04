import Foundation
import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Logo and Title
                VStack(spacing: 15) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    
                    Text("Nutrition Tracker")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 50)
                
                // Input Fields
                VStack(spacing: 20) {
                    CustomTextField(
                        icon: "envelope.fill",
                        placeholder: "Email",
                        text: $email
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    
                    CustomTextField(
                        icon: "lock.fill",
                        placeholder: "Password",
                        text: $password,
                        isSecure: true
                    )
                }
                .padding(.horizontal)
                
                // Sign In Button
                Button {
                    Task {
                        await userViewModel.signIn(email: email, password: password)
                    }
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(userViewModel.isLoading)
                
                // Create Account Button
                Button {
                    isSignUp = true
                } label: {
                    Text("Create Account")
                        .foregroundColor(.green)
                }
                
                if userViewModel.isLoading {
                    ProgressView()
                }
                
                Spacer()
            }
            .sheet(isPresented: $isSignUp) {
                CreateAccountView()
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
