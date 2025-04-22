import SwiftUI

struct BadgeDetailView: View {
    let badge: Badge
    let isEarned: Bool
    let dateEarned: Date?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                BadgeView(badge: badge, isEarned: isEarned, size: 120)

                VStack(spacing: 8) {
                    Text(badge.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(badge.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    if isEarned, let date = dateEarned {
                        Text("Earned on \(date.formatted(date: .abbreviated, time: .omitted))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        // Display how many goals are left if not earned
                        Text("Complete \(badge.goalCountRequired) goals to earn this badge")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Badge Details")
    }
}
