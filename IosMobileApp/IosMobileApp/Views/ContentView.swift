import SwiftUI

struct ContentView: View {
    @State private var currentTab = 0
    @EnvironmentObject var goalController: GoalController
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var badgeController: BadgeController

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    switch currentTab {
                    case 0:
                        HomeView(goals: $goalController.goals)
                    case 1:
                        GoalConnectPage()
                    case 2:
                        ProfileView()
                    default:
                        HomeView(goals: $goalController.goals)
                    }

                    BottomBarView(currentTab: $currentTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
            
            // Badge Alert Overlay
            if badgeController.showBadgeAlert, let badge = badgeController.newlyEarnedBadge {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .overlay {
                        BadgeAlertView(badge: badge) {
                            badgeController.dismissBadgeAlert()
                        }
                    }
                    .transition(.opacity)
            }
        }
        .onAppear {
            Task {
                await goalController.loadGoals()
                if let userId = authController.currentUser?.id {
                    await badgeController.loadBadges(for: userId)
                }
            }
        }
    }
}
