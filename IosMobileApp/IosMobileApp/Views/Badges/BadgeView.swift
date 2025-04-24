import SwiftUI

struct BadgeView: View {
    let badge: Badge
    let isEarned: Bool
    let size: CGFloat
    
    private var imageName: String {
        // Handle the EXPERT case which is uppercase in assets
        if badge.id == "expert" {
            return "EXPERT"
        }
        return badge.id
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .saturation(isEarned ? 1 : 0)
                    .opacity(isEarned ? 1 : 0.3)
                
                if !isEarned {
                    Image(systemName: "lock.fill")
                        .font(.system(size: size * 0.4))
                        .foregroundColor(.gray)
                        .background(
                            Circle()
                                .fill(Color(.systemBackground))
                                .frame(width: size * 0.5, height: size * 0.5)
                        )
                }
            }
            
            VStack(spacing: 2) {
                Text(badge.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isEarned ? .primary : .secondary)
                
                Text("\(badge.goalCountRequired) goals")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .frame(width: size * 1.2)
    }
}

#Preview {
    BadgeView(badge: Badge.allBadges[0], isEarned: true, size: 80)
} 