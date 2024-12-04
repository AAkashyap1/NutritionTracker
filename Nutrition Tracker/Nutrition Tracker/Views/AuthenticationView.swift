//
//  AuthenticationScreen.swift
//  Nutrition Tracker
//
//  Created by Ananth Kashyap on 12/4/24.
//

import Foundation
import SwiftUI

struct AuthenticationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp = false
    @State private var isAuthenticated = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                    .padding(.top, 50)
                
                Text("Nutrition Tracker")
                    .font(.system(size: 32, weight: .bold))
                
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email)
                        .autocapitalization(.none)
                    
                    CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                    
                    Button(action: {
                        isAuthenticated = true
                    }) {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                    }
                }
                .padding(.horizontal, 30)
                
                Button(action: { isSignUp.toggle() }) {
                    Text("Don't have an account? Sign Up")
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            .sheet(isPresented: $isSignUp) {
                CreateAccountView()
            }
            .fullScreenCover(isPresented: $isAuthenticated) {
                HomePageView()
            }
        }
    }
}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticationView()
    }
}
