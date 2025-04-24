import SwiftUI

struct BadgeCollectionView: View {
    @State private var allBadges: [Badge] = []
    @State private var earnedBadgeIds: [String] = []
    @State private var selectedBadge: Badge?
    @State private var isLoading = true
    
    let badgeRepository: BadgeRepository
    let userId: UUID
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading badges...")
            } else {
                ScrollView {
                    VStack {
                        // Debug info
                        Text("All Badges: \(allBadges.count)")
                        Text("Earned Badges: \(earnedBadgeIds.count)")
                        
                        let earnedCount = earnedBadgeIds.count
                        let totalCount = allBadges.count
                        let progress = totalCount > 0 ? Double(earnedCount) / Double(totalCount) : 0

                        VStack {
                            Text("Badge Progress")
                                .font(.headline)
                            ProgressView(value: progress)
                                .padding(.horizontal)
                            Text("\(earnedCount) of \(totalCount) badges earned")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 20) {
                            ForEach(allBadges) { badge in
                                Button(action: {
                                    selectedBadge = badge
                                }) {
                                    BadgeView(
                                        badge: badge,
                                        isEarned: earnedBadgeIds.contains(badge.id),
                                        size: 60
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.bottom)
                    }
                }
            }
        }
        .task {
            await loadBadges()
        }
        .sheet(item: $selectedBadge) { badge in
            BadgeDetailView(
                badge: badge,
                isEarned: earnedBadgeIds.contains(badge.id),
                dateEarned: earnedBadgeIds.contains(badge.id) ? Date() : nil
            )
        }
    }
    
    private func loadBadges() async {
        do {
            allBadges = try await badgeRepository.getAllBadges()
            let earnedBadges = try await badgeRepository.getBadgesForUser(userId: userId)
            earnedBadgeIds = earnedBadges.map { $0.id }
            isLoading = false
        } catch {
            print("Error loading badges: \(error)")
            isLoading = false
        }
    }
}

struct BadgeCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        let dbQueue = DatabaseManager.shared.getDatabase()
        let badgeRepository = BadgeRepository(dbQueue: dbQueue)
        
        return BadgeCollectionView(
            badgeRepository: badgeRepository,
            userId: UUID() // Use a test UUID for preview
        )
    }
}
