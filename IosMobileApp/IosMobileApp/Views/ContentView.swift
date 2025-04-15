import SwiftUI

struct ContentView: View {
    @State private var currentTab = 0
    @State private var goals: [Goal] = []

    @EnvironmentObject var goalRepository: GoalRepository

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack(alignment: .bottom) {
                    switch currentTab {
                    case 0:
                        HomeView(goals: $goals)
                    case 1:
                        GoalConnectPage()
                    default:
                        HomeView(goals: $goals)
                    }

                    BottomBarView(currentTab: $currentTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear {
            Task {
                do {
                    self.goals = try goalRepository.getGoals()
                } catch {
                    print("Failed to fetch goals: \(error)")
                }
            }
        }
    }
}
