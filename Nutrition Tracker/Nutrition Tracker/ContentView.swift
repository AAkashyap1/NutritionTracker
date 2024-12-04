import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        Group {
            if userViewModel.isAuthenticated {
                HomePageView()
            } else {
                AuthenticationView()
            }
        }
        .alert("Error", isPresented: .constant(userViewModel.error != nil)) {
            Button("OK") { userViewModel.clearError() }
        } message: {
            Text(userViewModel.error?.localizedDescription ?? "")
        }
    }
}

#Preview {
    ContentView()
}
