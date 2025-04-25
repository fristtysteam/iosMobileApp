import SwiftUI

struct BadgeAlertView: View {
    let badge: Badge
    let onDismiss: () -> Void
    @State private var showAnimation = false
    @State private var showBadgesCollection = false
    
    private var imageName: String {
        // Handle the EXPERT case which is uppercase in assets
        if badge.id == "expert" {
            return "EXPERT"
        }
        return badge.id
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .scaleEffect(showAnimation ? 1.0 : 0.1)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showAnimation)
            
            Text("New Badge Earned!")
                .font(.title2)
                .fontWeight(.bold)
                .opacity(showAnimation ? 1 : 0)
                .offset(y: showAnimation ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.3), value: showAnimation)
            
            Text(badge.name)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
                .opacity(showAnimation ? 1 : 0)
                .offset(y: showAnimation ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.4), value: showAnimation)
            
            Text(badge.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .opacity(showAnimation ? 1 : 0)
                .offset(y: showAnimation ? 0 : 20)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: showAnimation)
            
            VStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
                
                Button(action: {
                    showBadgesCollection = true
                    onDismiss()
                }) {
                    Text("View All Badges")
                        .font(.subheadline)
                        .foregroundColor(.purple)
                }
            }
            .padding(.top)
            .opacity(showAnimation ? 1 : 0)
            .offset(y: showAnimation ? 0 : 20)
            .animation(.easeOut(duration: 0.5).delay(0.6), value: showAnimation)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 20)
        )
        .padding(30)
        .onAppear {
            showAnimation = true
        }
    }
} 