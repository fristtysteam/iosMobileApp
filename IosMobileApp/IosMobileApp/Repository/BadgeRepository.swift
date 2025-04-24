import Foundation
import GRDB
import SwiftUI

@MainActor
class BadgeRepository: ObservableObject {
    @Published private(set) var allBadges: [Badge] = []
    @Published private(set) var isLoading = false
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    // Fetch all badges from the database
    func getAllBadges() async throws -> [Badge] {
        isLoading = true
        defer { isLoading = false }
        
        let badges = try await dbQueue.read { db in
            try Badge.fetchAll(db)
        }
        await MainActor.run {
            self.allBadges = badges
        }
        return badges
    }

    // Fetch all badges earned by a specific user
    func getBadgesForUser(userId: UUID) async throws -> [Badge] {
        isLoading = true
        defer { isLoading = false }
        
        return try await dbQueue.read { db in
            let earnedBadgeIds = try UserBadge
                .filter(Column("userId") == userId.uuidString) // Convert UUID to String
                .fetchAll(db)
                .map { $0.badgeId }

            return try Badge.filter(earnedBadgeIds.contains(Column("id"))).fetchAll(db)
        }
    }

    // Check for new badges that the user can earn based on their completed goals
    func checkForNewBadges(userId: UUID, completedGoalsCount: Int) async throws -> [Badge] {
        isLoading = true
        defer { isLoading = false }
        
        return try await dbQueue.read { db in
            let earnedBadgeIds = try UserBadge
                .filter(Column("userId") == userId.uuidString)  // Convert UUID to String
                .fetchAll(db)
                .map { $0.badgeId }

            // Find badges that the user has not earned yet and can still earn based on their completed goals
            return try Badge
                .filter(Column("goalCountRequired") <= completedGoalsCount)
                .filter(!earnedBadgeIds.contains(Column("id")))
                .fetchAll(db)
        }
    }

    // Award a badge to the user
    func awardBadge(userId: UUID, badgeId: String) async throws {
        try await dbQueue.write { db in
            let userBadge = UserBadge(userId: userId, badgeId: badgeId)
            try userBadge.insert(db)
        }
    }

    // Get recently earned badges for a user
    func getRecentlyEarnedBadges(userId: UUID, limit: Int = 3) async throws -> [Badge] {
        isLoading = true
        defer { isLoading = false }
        
        return try await dbQueue.read { db in
            let earned = try UserBadge
                .filter(Column("userId") == userId.uuidString)  // Convert UUID to string
                .order(Column("dateEarned").desc)
                .limit(limit)
                .fetchAll(db)

            let earnedIds = earned.map { $0.badgeId }
            return try Badge.filter(earnedIds.contains(Column("id"))).fetchAll(db)
        }
    }
    
    // Debug function to print all badges
    func printAllBadges() async throws {
        try await dbQueue.read { db in
            let badges = try Badge.fetchAll(db)
            print("All badges in database:")
            badges.forEach { print("- \($0.name) (\($0.id))") }
        }
    }

    // Debug function to print user's badges
    func printUserBadges(userId: UUID) async throws {
        try await dbQueue.read { db in
            let userBadges = try UserBadge.filter(Column("userId") == userId.uuidString).fetchAll(db)
            print("User \(userId) has badges:")
            userBadges.forEach { print("- \($0.badgeId) earned on \($0.dateEarned)") }
        }
    }

    func initializeBadges() async throws {
        try await dbQueue.write { db in
            // Only insert if the table is empty
            if try Badge.fetchCount(db) == 0 {
                for badge in Badge.allBadges {
                    try badge.insert(db)
                }
                print("Initialized \(Badge.allBadges.count) badges in database")
            }
        }
    }

    // Get user badges with earned dates
    func getUserBadges(userId: UUID) async throws -> [UserBadge] {
        return try await dbQueue.read { db in
            try UserBadge
                .filter(Column("userId") == userId.uuidString)
                .order(Column("dateEarned").desc)
                .fetchAll(db)
        }
    }

    // Get completed goals count for a user
    func getCompletedGoalsCount(userId: UUID) async throws -> Int {
        return try await dbQueue.read { db in
            try Goal
                .filter(Column("userId") == userId.uuidString)
                .filter(Column("isCompleted") == true)
                .fetchCount(db)
        }
    }
}
