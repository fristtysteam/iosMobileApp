import SwiftUI

struct BottomBar: View {
    @Binding var selectedTab: TabDestination?

    var homeAction: () -> Void
    var goalsAction: () -> Void
    var profileAction: () -> Void
    var settingsAction: () -> Void
    var helpAction: () -> Void
    var logoutAction: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            BottomBarItem(
                icon: "house.fill",
                label: "Home",
                isSelected: selectedTab == .home,
                action: {
                    selectedTab = .home
                    homeAction()
                }
            )
            BottomBarItem(
                icon: "target",
                label: "Goals",
                isSelected: selectedTab == .goals,
                action: {
                    selectedTab = .goals
                    goalsAction()
                }
            )
            BottomBarItem(
                icon: "person.crop.circle",
                label: "Profile",
                isSelected: selectedTab == .profile,
                action: {
                    selectedTab = .profile
                    profileAction()
                }
            )

            Menu {
                Button("Settings", action: {
                    selectedTab = .settings
                    settingsAction()
                })
                Button("Help", action: {
                    selectedTab = .help
                    helpAction()
                })
                Button("Logout", action: {
                    selectedTab = .logout
                    logoutAction()
                })
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity)
                .foregroundColor(
                    [.settings, .help, .logout].contains(selectedTab ?? .home)
                        ? .blue
                        : .primary
                )
            }
        }
        .frame(height: 70)
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
        .shadow(radius: 3)
    }
}


struct BottomBarItem: View {
    var icon: String
    var label: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.caption)
            }
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .foregroundColor(.primary)
        }
    }
}


#Preview {
    VStack {
        Spacer()
        BottomBar(
            selectedTab: .constant(.home),
            homeAction: { print("Home tapped") },
            goalsAction: { print("Goals tapped") },
            profileAction: { print("Profile tapped") },
            settingsAction: { print("Settings") },
            helpAction: { print("Help") },
            logoutAction: { print("Logout") }
        )
    }
    .edgesIgnoringSafeArea(.bottom)
}
