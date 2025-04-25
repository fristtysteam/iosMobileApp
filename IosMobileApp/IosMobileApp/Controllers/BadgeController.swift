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
            // Error handled silently
        }
    }
    
    func checkAndAwardBadges(for userId: UUID) async {
        do {
            let completedCount = try await userRepository.getCompletedGoalsCount(userId: userId)
            let newBadges = try await badgeRepository.checkForNewBadges(userId: userId, completedGoalsCount: completedCount)
            
            for badge in newBadges {
                do {
                    try await badgeRepository.awardBadge(userId: userId, badgeId: badge.id)
                    await showBadgeEarnedCelebration(badge: badge)
                } catch {
                    // Error handled silently
                }
            }
            
            if !newBadges.isEmpty {
                await loadBadges(for: userId)
            }
        } catch {
            // Error handled silently
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