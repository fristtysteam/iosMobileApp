import SwiftUI

struct HeaderView: View {
    let title: String
    let useGradient: Bool
    
    init(title: String, useGradient: Bool = false) {
        self.title = title
        self.useGradient = useGradient
    }

    var body: some View {
        HStack {
            // Title with optional gradient
            if useGradient {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            } else {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            Spacer()

            // Notification Icon
            Image(systemName: "bell.fill")
                .font(.title)
                .foregroundColor(.black)
                .onTapGesture {
                    print("Notification tapped!")
                }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 20) {
        HeaderView(title: "Achievr")
        HeaderView(title: "Goal Connect", useGradient: true)
    }
}
