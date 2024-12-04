//
//  ProfileView.swift
//  Nutrition Tracker
//
//  Created by Ananth Kashyap on 12/4/24.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var user = User(
        name: "John Doe",
        age: 28,
        weight: 75.0,
        height: 175.0,
        goalWeight: 70.0,
        joinDate: Date()
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Active since \(user.joinDate.formatted(date: .abbreviated, time: .omitted))")
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    StatCard(title: "Current Weight", value: "\(Int(user.weight)) kg", icon: "scalemass.fill")
                    StatCard(title: "Goal Weight", value: "\(Int(user.goalWeight)) kg", icon: "target")
                    StatCard(title: "Height", value: "\(Int(user.height)) cm", icon: "arrow.up.and.down")
                    StatCard(title: "Age", value: "\(user.age)", icon: "number")
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Settings")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        SettingsRow(icon: "gear", title: "Preferences")
                        SettingsRow(icon: "bell", title: "Notifications")
                        SettingsRow(icon: "target", title: "Goals")
                        SettingsRow(icon: "arrow.counterclockwise", title: "Reset Progress")
                        SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out")
                    }
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
