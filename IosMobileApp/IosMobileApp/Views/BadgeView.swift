import SwiftUI

struct BadgeView: View {
    let badge: Badge
    let isEarned: Bool
    let size: CGFloat
    
    var body: some View {
        VStack(spacing: 4) {
            // Badge icon
            ZStack {
                Circle()
                    .fill(isEarned ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.1))
                    .frame(width: size, height: size)
                
                Image(systemName: badge.imageName)
                    .font(.system(size: size * 0.5))
                    .foregroundColor(isEarned ? .yellow : .gray)
                    .shadow(color: isEarned ? .yellow : .clear, radius: 5)
            }
            .overlay(
                Circle()
                    .stroke(isEarned ? Color.yellow : Color.gray, lineWidth: 2)
            )
            
            // Badge name
            Text(badge.name)
                .font(.system(size: size * 0.15))
                .fontWeight(.medium)
                .lineLimit(1)
                .frame(width: size + 20)
            
            // Requirements (only show if not earned)
            if !isEarned {
                Text("\(badge.goalCountRequired) goals")
                    .font(.system(size: size * 0.12))
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size + 30)
    }
}
