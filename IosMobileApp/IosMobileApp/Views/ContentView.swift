import SwiftUI

struct ContentView: View {
    @State private var currentTab = 0
    @EnvironmentObject var goalController: GoalController

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    switch currentTab {
                    case 0:
                        HomeView(goals: $goalController.goals)
                    case 1:
                        GoalConnectPage()
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
