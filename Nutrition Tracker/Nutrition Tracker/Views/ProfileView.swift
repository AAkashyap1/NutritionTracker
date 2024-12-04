import Foundation
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 15) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text(userViewModel.currentUser?.name ?? "User")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if let joinDate = userViewModel.currentUser?.createdAt {
                        Text("Active since \(joinDate.formatted(date: .abbreviated, time: .omitted))")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 40)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    StatCard(title: "Current Weight", value: "\(Int(userViewModel.currentUser?.weight ?? 0)) kg", icon: "scalemass.fill")
                    StatCard(title: "Goal Weight", value: "\(Int(userViewModel.currentUser?.goalWeight ?? 0)) kg", icon: "target")
                    StatCard(title: "Height", value: "\(Int(userViewModel.currentUser?.height ?? 0)) cm", icon: "arrow.up.and.down")
                    StatCard(title: "Age", value: "\(userViewModel.currentUser?.age ?? 0)", icon: "number")
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
                        Button(action: { userViewModel.signOut() }) {
                            SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out")
                        }
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
