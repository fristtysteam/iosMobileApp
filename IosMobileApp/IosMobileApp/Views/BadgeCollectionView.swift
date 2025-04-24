import SwiftUI

struct BadgeCollectionView: View {
    @EnvironmentObject var userRepository: UserRepository
    @EnvironmentObject var authController: AuthController
    @State private var earnedBadges: [Badge] = []
    private let allBadges = Badge.allBadges

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your Badge Progress")
                .font(.title)
                .bold()

            BadgeProgressBar(earnedCount: earnedBadges.count, totalCount: allBadges.count)

            Text("Badges")
                .font(.headline)
                .padding(.top)

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 20) {
                    ForEach(allBadges) { badge in
                        BadgeItemView(badge: badge, isEarned: earnedBadges.contains(where: { $0.id == badge.id }))
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .task {
            await loadEarnedBadges()
        }
    }

    private func loadEarnedBadges() async {
        guard let currentUser = authController.currentUser else { return }
        do {
            let badges = try await userRepository.getUserBadges(userId: currentUser.id)
            earnedBadges = badges
        } catch {
            print("Failed to load badges: \(error)")
        }
    }
}

// MARK: - Progress Bar View

struct BadgeProgressBar: View {
    let earnedCount: Int
    let totalCount: Int

    var body: some View {
        let progress: Double = totalCount > 0 ? Double(earnedCount) / Double(totalCount) : 0

        VStack(alignment: .leading) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
            Text("\(earnedCount) of \(totalCount) badges earned")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Badge Item View

struct BadgeItemView: View {
    let badge: Badge
    let isEarned: Bool

    var body: some View {
        VStack {
            Image(systemName: badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(isEarned ? .accentColor : .gray)
                .opacity(isEarned ? 1.0 : 0.3)

            Text(badge.name)
                .font(.caption)
                .fontWeight(isEarned ? .bold : .regular)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
