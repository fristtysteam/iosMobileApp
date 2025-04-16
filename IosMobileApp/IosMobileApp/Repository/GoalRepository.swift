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
    func getGoalByID(goalID: UUID) async throws -> Goal? {
        try await dbQueue.read { db in
            try Goal.filter(Column("id") == goalID.uuidString).fetchOne(db)
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
    
    // Clear all goals
    func clearAllGoals() throws {
        try dbQueue.write { db in
            _ = try Goal.deleteAll(db)
        }
    }
}
