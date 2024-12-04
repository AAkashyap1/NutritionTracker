//
//  Models.swift
//  Nutrition Tracker
//
//  Created by Ananth Kashyap on 12/4/24.
//

import Foundation
// Models.swift
import SwiftUI

struct User: Identifiable {
    let id = UUID()
    var name: String
    var age: Int
    var weight: Double
    var height: Double
    var goalWeight: Double
    var joinDate: Date
}

struct NutritionGoals {
    var dailyCalories: Double
    var protein: Double
    var carbs: Double
    var fats: Double
    var fiber: Double
    var water: Double
}

struct DailyProgress {
    var calories: Double
    var protein: Double
    var carbs: Double
    var fats: Double
    var fiber: Double
    var water: Double
}
