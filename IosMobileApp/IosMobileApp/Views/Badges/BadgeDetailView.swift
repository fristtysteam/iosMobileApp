import SwiftUI
import GRDB

struct BadgeDetailView: View {
    let badge: Badge
    let isEarned: Bool
    let dateEarned: Date?
    @StateObject private var badgeRepository: BadgeRepository
    
    init(badge: Badge, isEarned: Bool, dateEarned: Date?) {
        self.badge = badge
        self.isEarned = isEarned
        self.dateEarned = dateEarned
        self._badgeRepository = StateObject(wrappedValue: BadgeRepository(dbQueue: DatabaseManager.shared.getDatabase()))
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Image(badge.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .saturation(isEarned ? 1 : 0)
                    .opacity(isEarned ? 1 : 0.3)
                
                if !isEarned {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: 80, height: 80)
                        )
                }
            }
            
            VStack(spacing: 8) {
                Text(badge.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(isEarned ? .primary : .secondary)
                
                Text(badge.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                if isEarned {
                    earnedBadgeInfo
                } else {
                    lockedBadgeInfo
                }
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var earnedBadgeInfo: some View {
        VStack(spacing: 12) {
            Label("Badge Earned!", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundColor(.green)
            
            if let dateEarned = dateEarned {
                Text("Earned on: \(dateEarned.formatted(date: .long, time: .omitted))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
    
    private var lockedBadgeInfo: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Requirements to Unlock")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Complete \(badge.goalCountRequired) goals")
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            VStack(spacing: 8) {
                Text("Keep Going!")
                    .font(.headline)
                    .foregroundColor(.purple)
                
                Text("Complete more goals to unlock this badge")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}

#Preview {
    let dbQueue = try! DatabaseQueue()
    let badgeRepository = BadgeRepository(dbQueue: dbQueue)
    
    return NavigationView {
        BadgeDetailView(
            badge: Badge.allBadges[0],
            isEarned: false,
            dateEarned: nil
        )
    }
} 