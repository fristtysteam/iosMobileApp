import Foundation
import GRDB

struct BadgeRepository {
    private let dbQueue: DatabaseQueue

    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }

    func getAllBadges() async throws -> [Badge] {
        try await dbQueue.read { db in
            try Badge.fetchAll(db)
        }
    }

    func getBadgesForUser(userId: UUID) async throws -> [Badge] {
        try await dbQueue.read { db in
            // Fix: Use the proper association for joining
            let badges = try Badge
                .including(required: Badge.userBadges) // Use including here for relationships
                .filter(UserBadge.Columns.userId == userId) // Filter by userId
                .fetchAll(db)
            return badges
        }
    }

    func getRecentlyEarnedBadges(userId: UUID) async throws -> [Badge] {
        try await dbQueue.read { db in
            let userBadges = try UserBadge
                .filter(UserBadge.Columns.userId == userId)
                .order(UserBadge.Columns.dateEarned.desc)
                .limit(5)
                .including(required: UserBadge.badge) // Include the badge in the result
                .fetchAll(db)

            return userBadges.map { $0.badge }
        }
    }

    func checkForNewBadges(userId: UUID, completedGoalsCount: Int) async throws -> [Badge] {
        try await dbQueue.read { db in
            let eligibleBadges = try Badge
                .filter(Badge.Columns.goalCountRequired <= completedGoalsCount)
                .fetchAll(db)

            let userBadgeIds = try UserBadge
                .filter(UserBadge.Columns.userId == userId)
                .fetchAll(db)
                .map { $0.badgeId }

            return eligibleBadges.filter { !userBadgeIds.contains($0.id) }
        }
    }

    func awardBadge(userId: UUID, badgeId: String) async throws {
        try await dbQueue.write { db in
            let alreadyHasBadge = try UserBadge
                .filter(UserBadge.Columns.userId == userId && UserBadge.Columns.badgeId == badgeId)
                .fetchCount(db) > 0

            if !alreadyHasBadge {
                let userBadge = UserBadge(userId: userId, badgeId: badgeId, dateEarned: Date())
                try userBadge.insert(db)
            }
        }
    }

    func initializeBadges() async throws {
        try await dbQueue.write { db in
            let count = try Badge.fetchCount(db)
            if count == 0 {
                for badge in Badge.allBadges {
                    try badge.insert(db)
                }
            }
        }
    }
}
