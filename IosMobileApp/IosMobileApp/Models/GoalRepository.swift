import Foundation
import GRDB

class GoalRepository: ObservableObject {
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    // Fetch all goals
    func getGoals() throws -> [Goal] {
        try dbQueue.read { db in
            try Goal.fetchAll(db)
        }
    }

    // Fetch goal by ID
    func getGoalByID(goalID: UUID) -> Goal? {
        do {
            let goals = try dbQueue.read { db in
                try Goal.fetchAll(db, sql: "SELECT * FROM goal WHERE id = ?", arguments: [goalID.uuidString])
            }
            return goals.first
        } catch {
            print("Error fetching goal: \(error)")
            return nil
        }
    }

    // Save a goal
    func saveGoal(_ goal: Goal) throws {
        try dbQueue.write { db in
            try goal.save(db)
        }
    }

    // Delete a goal
    func deleteGoal(_ goal: Goal) throws {
        try dbQueue.write { db in
            try goal.delete(db)
        }
    }
}
