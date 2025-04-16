import SwiftUI

struct ContentView: View {
    @State private var currentTab = 0
    @EnvironmentObject var goalController: GoalController
    @EnvironmentObject var authController: AuthController

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
        }
        .onAppear {
            Task {
                await goalController.loadGoals()
            }
        }
    }
}
