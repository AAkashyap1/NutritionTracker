//
//  HomePageView.swift
//  Nutrition Tracker
//
//  Created by Ananth Kashyap on 12/3/24.
//

import Foundation
import SwiftUI

struct HomePageView: View {
    @State private var dailyProgress = DailyProgress(
        calories: 1200,
        protein: 75,
        carbs: 150,
        fats: 50,
        fiber: 20,
        water: 1.5
    )
    
    @State private var goals = NutritionGoals(
        dailyCalories: 2000,
        protein: 150,
        carbs: 200,
        fats: 70,
        fiber: 30,
        water: 3.0
    )
    
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
                            CircularProgressBar(progress: dailyProgress.calories / goals.dailyCalories)
                                .frame(width: 120, height: 120)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Daily Calories")
                                    .font(.headline)
                                Text("\(Int(dailyProgress.calories))/\(Int(goals.dailyCalories))")
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
                        VStack(alignment: .leading, spacing: 15) {  // Added alignment: .leading here
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.green)
                                Text("Macros")
                                    .font(.headline)
                            }
                            
                            MacroProgressBar(label: "Protein", value: dailyProgress.protein, goal: goals.protein, color: .blue)
                            MacroProgressBar(label: "Carbs", value: dailyProgress.carbs, goal: goals.carbs, color: .green)
                            MacroProgressBar(label: "Fats", value: dailyProgress.fats, goal: goals.fats, color: .orange)
                            MacroProgressBar(label: "Fiber", value: dailyProgress.fiber, goal: goals.fiber, color: .purple)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(15)
                        .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    
                    WaterProgressCard(intake: dailyProgress.water, goal: goals.water)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Quick Actions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            NavigationLink(destination: AddWaterView()) {
                                QuickActionButton(title: "Add Water", icon: "drop.fill", color: .blue)
                            }
                            
                            NavigationLink(destination: AddFoodView()) {
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
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
