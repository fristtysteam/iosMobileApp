import SwiftUI

struct BadgeView: View {
    let badge: Badge
    let isEarned: Bool
    let size: CGFloat
    
    var body: some View {
        VStack {
            Image(systemName: badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .foregroundColor(isEarned ? .purple : .gray)
            
            Text(badge.name)
                .font(.caption)
                .foregroundColor(isEarned ? .primary : .secondary)
        }
    }
}

#Preview {
    BadgeView(badge: Badge.allBadges[0], isEarned: true, size: 50)
} 