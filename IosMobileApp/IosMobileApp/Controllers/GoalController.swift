import SwiftUI
import GRDB

@MainActor
class GoalController: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    private let goalRepository: GoalRepository
    private let authController: AuthController
    private let badgeController: BadgeController
    private let notificationService = NotificationService.shared

    init(goalRepository: GoalRepository, authController: AuthController, badgeController: BadgeController) {
        self.goalRepository = goalRepository
        self.authController = authController
        self.badgeController = badgeController
    }

    func loadGoals() async {
        isLoading = true
        do {
            goals = try await goalRepository.getGoals()
            errorMessage = nil
            showError = false
        } catch {
            errorMessage = "Failed to load goals: \(error.localizedDescription)"
            showError = true
        }
        isLoading = false
    }

    func createGoal(title: String, description: String?, category: String?, deadline: Date?, progress: Double, isCompleted: Bool) async -> UUID? {
        isLoading = true
        do {
            guard let currentUserId = authController.currentUser?.id else {
                errorMessage = "No user logged in"
                showError = true
                return nil
            }

            let newGoal = Goal(
                userId: currentUserId,
                title: title,
                description: description,
                category: category,
                deadline: deadline,
                progress: progress,
                isCompleted: isCompleted
            )

            try await goalRepository.saveGoal(newGoal)
            notificationService.notifyGoalCreated(goal: newGoal)
            await loadGoals()
            return newGoal.id
        } catch {
            errorMessage = "Failed to create goal: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return nil
        }
    }

    func updateGoal(_ goal: Goal) async -> Bool {
        isLoading = true
        do {
            var updatedGoal = goal
            
            // Ensure progress is 100% when goal is marked as complete
            if updatedGoal.isCompleted {
                updatedGoal.progress = 1.0
            }
            
            try await goalRepository.saveGoal(updatedGoal)
            await loadGoals()
            
            // Check for badges if the goal is completed
            if updatedGoal.isCompleted, let userId = authController.currentUser?.id {
                await badgeController.checkAndAwardBadges(for: userId)
            }
            
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to update goal: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }

    func deleteGoal(_ goal: Goal) async -> Bool {
        isLoading = true
        do {
            try await goalRepository.deleteGoal(goal)
            notificationService.notifyGoalDeleted(goal: goal)
            await loadGoals()
            isLoading = false
            return true
        } catch {
            errorMessage = "Failed to delete goal: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }

    func getGoalByID(_ id: UUID) async -> Goal? {
        do {
            if let goal = goals.first(where: { $0.id == id }) {
                return goal
            }
            if let goal = try await goalRepository.getGoalByID(goalID: id) {
                return goal
            } else {
                errorMessage = "Goal not found"
                showError = true
                return nil
            }
        } catch {
            errorMessage = "Failed to fetch goal: \(error.localizedDescription)"
            showError = true
            return nil
        }
    }

    func clearAllGoals() async -> Bool {
        isLoading = true
        do {
            try await goalRepository.clearAllGoals()
            await loadGoals()
            return true
        } catch {
            errorMessage = "Failed to clear goals: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }

    func completeGoal(goal: Goal) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            guard let currentUserId = authController.currentUser?.id else {
                errorMessage = "No user logged in"
                showError = true
                return false
            }

            var completedGoal = goal
            completedGoal.isCompleted = true
            completedGoal.progress = 1.0

            try await goalRepository.saveGoal(completedGoal)
            await badgeController.checkAndAwardBadges(for: currentUserId)
            await loadGoals()
            return true
        } catch {
            errorMessage = "Failed to complete goal: \(error.localizedDescription)"
            showError = true
            return false
        }
    }

    func clearError() {
        errorMessage = nil
        showError = false
    }
}
