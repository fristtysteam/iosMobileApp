import SwiftUI
import GRDB

@MainActor
class GoalController: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let goalRepository: GoalRepository
    
    init(goalRepository: GoalRepository) {
        self.goalRepository = goalRepository
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
            let newGoal = Goal(
                title: title,
                description: description,
                category: category,
                deadline: deadline,
                progress: progress,
                isCompleted: isCompleted
            )
            
            try await goalRepository.saveGoal(newGoal)
            await loadGoals() // Refresh goals list
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
            try await goalRepository.saveGoal(goal)
            await loadGoals() // Refresh goals list
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
            await loadGoals() // Refresh goals list
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
            // First try to find the goal in the current goals array
            if let goal = goals.first(where: { $0.id == id }) {
                return goal
            }
            
            // If not found in memory, try to fetch from database
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
            await loadGoals() // Refresh goals list to empty array
            return true
        } catch {
            errorMessage = "Failed to clear goals: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return false
        }
    }
    
    // Helper method to clear any errors
    func clearError() {
        errorMessage = nil
        showError = false
    }
} 