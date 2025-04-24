import SwiftUI

struct BadgeCollectionView: View {
    @State private var allBadges: [Badge] = []
    @State private var earnedBadges: [UserBadge] = []
    @State private var selectedBadge: Badge?
    @State private var isLoading = true
    @State private var completedGoalsCount: Int = 0
    
    let badgeRepository: BadgeRepository
    let userId: UUID
    
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 120), spacing: 16)
    ]
    
    private var achievableBadges: [Badge] {
        allBadges.filter { $0.goalCountRequired <= completedGoalsCount }
    }
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading badges...")
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        progressSection
                        badgesGrid
                    }
                    .padding(.vertical)
                }
            }
        }
        .task {
            await loadBadges()
        }
        .sheet(item: $selectedBadge) { badge in
            NavigationView {
                BadgeDetailView(
                    badge: badge,
                    isEarned: earnedBadges.contains(where: { $0.badgeId == badge.id }),
                    dateEarned: earnedBadges.first(where: { $0.badgeId == badge.id })?.dateEarned
                )
                .navigationBarItems(trailing: Button("Done") {
                    selectedBadge = nil
                })
            }
        }
    }
    
    private var progressSection: some View {
        let earnedCount = earnedBadges.count
        let achievableCount = achievableBadges.count
        let progress = achievableCount > 0 ? Double(earnedCount) / Double(achievableCount) : 0
        
        return VStack(spacing: 16) {
            Text("Badge Progress")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 24) {
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 100, height: 100)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                    
                    VStack(spacing: 4) {
                        Text("\(earnedCount)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("of \(achievableCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(progress * 100))% Complete")
                        .font(.headline)
                    
                    if achievableCount < allBadges.count {
                        Text("Complete more goals to unlock new badges!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Keep going to earn all badges!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
    
    private var badgesGrid: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(allBadges.sorted { $0.goalCountRequired < $1.goalCountRequired }) { badge in
                Button(action: {
                    selectedBadge = badge
                }) {
                    BadgeView(
                        badge: badge,
                        isEarned: earnedBadges.contains(where: { $0.badgeId == badge.id }),
                        size: 80
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
    
    private func loadBadges() async {
        do {
            async let allBadgesTask = badgeRepository.getAllBadges()
            async let userBadgesTask = badgeRepository.getUserBadges(userId: userId)
            async let completedGoalsTask = badgeRepository.getCompletedGoalsCount(userId: userId)
            
            let (fetchedAllBadges, fetchedUserBadges, fetchedCompletedGoals) = await (
                try allBadgesTask,
                try userBadgesTask,
                try completedGoalsTask
            )
            
            allBadges = fetchedAllBadges
            earnedBadges = fetchedUserBadges
            completedGoalsCount = fetchedCompletedGoals
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
            userId: UUID()
        )
    }
}
