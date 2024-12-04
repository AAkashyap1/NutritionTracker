import Foundation
import SwiftUI
import FirebaseAuth
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var dailyProgress = DailyProgress.empty
    @Published var nutritionGoals = NutritionGoals(dailyCalories: 0, protein: 0, carbs: 0, fats: 0, fiber: 0, water: 0)
    @Published var isLoading = false
    @Published var error: AppError?
    @Published var isAuthenticated = false
    
    private var cancellables = Set<AnyCancellable>()
    private let refreshInterval: TimeInterval = 300
    private var refreshTimer: Timer?
    
    init() {
        setupAuthStateListener()
        setupRefreshTimer()
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task {
                if let user = user {
                    try? await self?.fetchUserData(userId: user.uid)
                } else {
                    self?.handleSignOut()
                }
            }
        }
    }
    
    private func setupRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task {
                await self?.refreshData()
            }
        }
    }
    
    func refreshData() async {
        guard let userId = currentUser?.id else { return }
        await fetchDailyProgress(userId: userId)
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        do {
            let user = try await NetworkManager.shared.signIn(email: email, password: password)
            currentUser = user
            await fetchInitialData(userId: user.id)
            isAuthenticated = true
        } catch {
            self.error = error as? AppError ?? .unknown
        }
        isLoading = false
    }
    
    func createAccount(email: String, password: String, profile: User) async {
        isLoading = true
        do {
            let user = try await NetworkManager.shared.createAccount(email: email, password: password, profile: profile)
            currentUser = user
            await fetchInitialData(userId: user.id)
            isAuthenticated = true
        } catch {
            self.error = error as? AppError ?? .unknown
        }
        isLoading = false
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            handleSignOut()
        } catch {
            self.error = .authenticationError(error.localizedDescription)
        }
    }
    
    private func handleSignOut() {
        currentUser = nil
        dailyProgress = .empty
        nutritionGoals = NutritionGoals(dailyCalories: 0, protein: 0, carbs: 0, fats: 0, fiber: 0, water: 0)
        isAuthenticated = false
    }
    
    private func fetchInitialData(userId: String) async {
        async let progressTask = fetchDailyProgress(userId: userId)
        async let goalsTask = fetchNutritionGoals()
        
        do {
            _ = try await [progressTask, goalsTask]
        } catch {
            self.error = error as? AppError ?? .unknown
        }
    }
    
    private func fetchUserData(userId: String) async throws {
        currentUser = try await NetworkManager.shared.getUser(userId: userId)
    }
    
    private func fetchDailyProgress(userId: String) async {
        do {
            dailyProgress = try await NetworkManager.shared.getDailyProgress(userId: userId)
        } catch {
            self.error = error as? AppError ?? .unknown
        }
    }
    
    private func fetchNutritionGoals() async {
        guard let user = currentUser else { return }
        do {
            nutritionGoals = try await NetworkManager.shared.calculateTargets(profile: user)
        } catch {
            self.error = error as? AppError ?? .unknown
        }
    }
    
    func processNutritionLabel(image: Data) async {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        do {
            let nutritionData = try await NetworkManager.shared.processNutritionLabel(image: image, userId: userId)
            await fetchDailyProgress(userId: userId)
        } catch {
            self.error = error as? AppError ?? .unknown
        }
        isLoading = false
    }

    func processWaterBottle(image: Data) async {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        do {
            let waterData = try await NetworkManager.shared.processWaterBottle(image: image, userId: userId)
            await fetchDailyProgress(userId: userId)
        } catch {
            self.error = error as? AppError ?? .unknown
        }
        isLoading = false
    }
    
    func updateDailyProgress(progress: DailyProgress) async {
        guard let userId = currentUser?.id else { return }
        isLoading = true
        do {
            try await NetworkManager.shared.updateDailyProgress(userId: userId, progress: progress)
            await fetchDailyProgress(userId: userId)
        } catch {
            self.error = error as? AppError ?? .unknown
        }
        isLoading = false
    }
    
    func clearError() {
        error = nil
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
}
