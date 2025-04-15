//
//  GoalRepository.swift
//  IosMobileApp
//
//  Created by Student on 14/04/2025.
//

import Foundation
import GRDB

@MainActor
final class GoalRepository: ObservableObject {
    private let dbQueue: DatabaseQueue
    @Published var goals: [Goal] = []  // Add @Published property
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    // Create or update a goal
    func saveGoal(_ goal: Goal) throws {
        try dbQueue.write { db in
            try goal.save(db)
        }
    }
    
    // Fetch goals for a specific user
    func getGoals(for userId: UUID) throws -> [Goal] {
        try dbQueue.read { db in
            try Goal.filter(Goal.Columns.userId == userId.uuidString)
                   .order(Goal.Columns.deadline.desc)
                   .fetchAll(db)
        }
    }
    
    // Delete goal
    func deleteGoal(_ goal: Goal) throws {
        try dbQueue.write { db in
            try goal.delete(db)
        }
    }
    
    // Update goal progress
    func updateGoalProgress(id: UUID, progress: Double) throws {
        try dbQueue.write { db in
            if var goal = try Goal.fetchOne(db, key: id.uuidString) {
                goal.progress = progress
                try goal.update(db)
            }
        }
    }
}
