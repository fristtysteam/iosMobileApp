import SwiftUI
import GRDB

struct GoalDetailsView: View {
    let goalID: UUID
    @State private var goal: Goal?

    var body: some View {
        VStack {
            if let goal = goal {
                Text(goal.title)
                    .font(.headline)
                Text(goal.description ?? "No description")
                    .font(.subheadline)
                Text("Category: \(goal.category ?? "N/A")")
                Text("Progress: \(goal.progress * 100, specifier: "%.0f")%")
                Text("Deadline: \(goal.deadline?.formatted() ?? "N/A")")
                Text("Completed: \(goal.isCompleted ? "Yes" : "No")")
            } else {
                Text("Goal not found")
                    .font(.title)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadGoal()
        }
    }

    // Load goal from the repository
    private func loadGoal() {
        let dbQueue = DatabaseManager.shared.getDatabase() // Use the shared instance to get the dbQueue
        let repository = GoalRepository(dbQueue: dbQueue)
        if let fetchedGoal = repository.getGoalByID(goalID: goalID) {
            goal = fetchedGoal
        } else {
            goal = nil
        }
    }
}
