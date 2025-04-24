import SwiftUI
import GRDB

@MainActor
class BadgeController: ObservableObject {
    @Published var userBadges: [Badge] = []
    @Published var allBadges: [Badge] = []
    @Published var isLoading = false
    @Published var showBadgeAlert = false
    @Published var newlyEarnedBadge: Badge?
    
    private let badgeRepository: BadgeRepository
    private let userRepository: UserRepository
    
    init(badgeRepository: BadgeRepository, userRepository: UserRepository) {
        self.badgeRepository = badgeRepository
        self.userRepository = userRepository
    }
    
    func loadBadges(for userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            async let userBadgesTask = badgeRepository.getBadgesForUser(userId: userId)
            async let allBadgesTask = badgeRepository.getAllBadges()
            
            let (fetchedUserBadges, fetchedAllBadges) = await (try userBadgesTask, try allBadgesTask)
            
            userBadges = fetchedUserBadges
            allBadges = fetchedAllBadges
        } catch {
            print("Error loading badges: \(error)")
        }
    }
    
    func checkAndAwardBadges(for userId: UUID) async {
        do {
            let completedCount = try await userRepository.getCompletedGoalsCount(userId: userId)
            print("📊 User \(userId) has completed \(completedCount) goals")
            
            let newBadges = try await badgeRepository.checkForNewBadges(userId: userId, completedGoalsCount: completedCount)
            print("🔍 Found \(newBadges.count) new badges eligible for user")
            
            for badge in newBadges {
                do {
                    try await badgeRepository.awardBadge(userId: userId, badgeId: badge.id)
                    print("🏆 Awarded badge '\(badge.name)' to user \(userId)")
                    await showBadgeEarnedCelebration(badge: badge)
                } catch {
                    print("❌ Error awarding badge '\(badge.name)': \(error)")
                }
            }
            
            if !newBadges.isEmpty {
                await loadBadges(for: userId)
            }
        } catch {
            print("❌ Error checking and awarding badges: \(error)")
        }
    }
    
    private func showBadgeEarnedCelebration(badge: Badge) async {
        await MainActor.run {
            self.newlyEarnedBadge = badge
            self.showBadgeAlert = true
        }
    }
    
    func dismissBadgeAlert() {
        showBadgeAlert = false
        newlyEarnedBadge = nil
    }
} 