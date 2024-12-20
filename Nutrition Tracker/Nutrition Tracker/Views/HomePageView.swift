import Foundation
import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showingAddWater = false
    @State private var showingAddFood = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    HStack {
                        Text("Today's Progress")
                            .font(.system(size: 28, weight: .bold))
                        
                        Spacer()
                        
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                        }
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.green.opacity(0.1))
                        
                        HStack(spacing: 20) {
                            CircularProgressBar(progress: userViewModel.dailyProgress.calories / userViewModel.nutritionGoals.dailyCalories)
                                .frame(width: 120, height: 120)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Daily Calories")
                                    .font(.headline)
                                Text("\(Int(userViewModel.dailyProgress.calories))/\(Int(userViewModel.nutritionGoals.dailyCalories))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("kcal remaining")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.green)
                                Text("Macros")
                                    .font(.headline)
                            }
                            
                            MacroProgressBar(label: "Protein", value: userViewModel.dailyProgress.protein, goal: userViewModel.nutritionGoals.protein, color: .blue)
                            MacroProgressBar(label: "Carbs", value: userViewModel.dailyProgress.carbs, goal: userViewModel.nutritionGoals.carbs, color: .green)
                            MacroProgressBar(label: "Fats", value: userViewModel.dailyProgress.fats, goal: userViewModel.nutritionGoals.fats, color: .orange)
                            MacroProgressBar(label: "Fiber", value: userViewModel.dailyProgress.fiber, goal: userViewModel.nutritionGoals.fiber, color: .purple)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    
                    WaterProgressCard(intake: userViewModel.dailyProgress.water, goal: userViewModel.nutritionGoals.water)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            Button(action: { showingAddWater = true }) {
                                QuickActionButton(title: "Add Water", icon: "drop.fill", color: .blue)
                            }
                            
                            Button(action: { showingAddFood = true }) {
                                QuickActionButton(title: "Add Food", icon: "fork.knife", color: .green)
                            }
                            
                            NavigationLink(destination: ProfileView()) {
                                QuickActionButton(title: "Profile", icon: "person.fill", color: .purple)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await userViewModel.refreshDailyProgress()
                }
            }
            .sheet(isPresented: $showingAddWater) {
                AddWaterView()
            }
            .sheet(isPresented: $showingAddFood) {
                AddFoodView()
            }
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
