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
        VStack(spacing: 20) {
            Image(systemName: badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(isEarned ? .purple : .gray)
                .opacity(isEarned ? 1.0 : 0.3)
            
            Text(badge.name)
                .font(.title)
                .bold()
                .foregroundColor(isEarned ? .primary : .secondary)
            
            Text(badge.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(isEarned ? .primary : .secondary)
            
            VStack(spacing: 8) {
                Text("Requirements")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Complete \(badge.goalCountRequired) goals")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top)
            
            if isEarned {
                if let dateEarned = dateEarned {
                    Text("Earned on: \(dateEarned.formatted(date: .long, time: .omitted))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
            } else {
                Text("Not yet earned")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let dbQueue = try! DatabaseQueue()
    let badgeRepository = BadgeRepository(dbQueue: dbQueue)
    
    // Create a test badge
    let testBadge = Badge(
        id: "test",
        name: "Test Badge",
        description: "This is a test badge",
        imageName: "star.fill",
        goalCountRequired: 5
    )
    
    NavigationView {
        BadgeDetailView(
            badge: testBadge,
            isEarned: true,
            dateEarned: Date()
        )
    }
} 