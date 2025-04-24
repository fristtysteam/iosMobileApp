import SwiftUI
import GRDB

struct BadgeDetailView: View {
    let badge: Badge
    let isEarned: Bool
    let dateEarned: Date?
    
    @State private var similarBadges: [Badge] = []
    @State private var isLoadingSimilar = false
    
    let badgeRepository: BadgeRepository
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Badge display
                BadgeView(badge: badge, isEarned: isEarned, size: 120)
                    .padding(.top, 20)
                
                // Badge info
                VStack(spacing: 8) {
                    Text(badge.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(badge.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if isEarned {
                        if let date = dateEarned {
                            Text("Earned on \(date.formatted(date: .abbreviated, time: .omitted))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("You've earned this badge!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    } else {
                        VStack(spacing: 4) {
                            Text("Complete \(badge.goalCountRequired) goals to earn")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ProgressView(value: 0.0) // You could show progress here
                                .frame(width: 100)
                        }
                    }
                }
                
                // Similar badges section
                if !similarBadges.isEmpty {
                    Divider()
                        .padding(.vertical)
                    
                    VStack(alignment: .leading) {
                        Text("Similar Badges")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(similarBadges) { similarBadge in
                                    BadgeView(
                                        badge: similarBadge,
                                        isEarned: false, // Or pass actual earned status
                                        size: 60
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Badge Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadSimilarBadges()
        }
    }
    
    private func loadSimilarBadges() async {
        isLoadingSimilar = true
        defer { isLoadingSimilar = false }
        
        do {
            let badges = try await badgeRepository.getAllBadges()
            await MainActor.run {
                similarBadges = badges
                    .filter { $0.id != badge.id && $0.goalCountRequired >= badge.goalCountRequired }
                    .sorted { $0.goalCountRequired < $1.goalCountRequired }
                    .prefix(3)
                    .map { $0 }
            }
        } catch {
            print("Error loading similar badges: \(error)")
        }
    }
}
