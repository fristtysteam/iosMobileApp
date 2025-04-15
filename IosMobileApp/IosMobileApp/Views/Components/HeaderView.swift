import SwiftUI

struct HeaderView: View {
    let title: String

    var body: some View {
        HStack {
            // Profile Icon with NavigationLink to ProfileView
            NavigationLink(destination: ProfileSettingsView()) {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.blue)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    )
            }

            Spacer()

            // Title
            Text(self.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.blue)

            Spacer()

            // Notification Icon
            Image(systemName: "bell.fill")
                .font(.title)
                .foregroundColor(Color.blue)
                .onTapGesture {
                    print("Notification tapped!")
                }
        }
        .padding()
        .shadow(radius: 10)
        .frame(maxWidth: .infinity, alignment: .top)
    }
}

#Preview {
    HeaderView(title: "goal getter")
}
