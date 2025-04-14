import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabDestination? = .home
    @State private var navigationPath = NavigationPath()

    @State private var goals: [Goal] = [
        Goal(id: UUID(), title: "Learn SwiftUI", description: "Build a few UI components using SwiftUI", category: "Programming", deadline: Date().addingTimeInterval(60*60*24*7), progress: 40.0, isCompleted: false, progressDiary: ["Started learning", "Completed 2 tutorials"]),
        Goal(id: UUID(), title: "Finish reading book", description: "Finish reading 'The Swift Programming Language' book", category: "Reading", deadline: Date().addingTimeInterval(60*60*24*14), progress: 90, isCompleted: false, progressDiary: ["Read the first chapter", "Started chapter 2"]),
        Goal(id: UUID(), title: "Create a Personal Portfolio", description: "Build an online portfolio to showcase projects", category: "Design", deadline: Date().addingTimeInterval(60*60*24*30), progress: 10.0, isCompleted: false, progressDiary: ["Set up a GitHub repository", "Created initial HTML structure"]),
    ]

    @State private var quote: Quote?
    @State private var isLoadingQuote = false
    
    @State private var currentTab = 0

    var body: some View {
        ZStack{
            NavigationStack(path: $navigationPath) {
                ZStack(alignment: .bottom) {
                   
                    switch currentTab {
                    case 0:
                        HomeView(goals: $goals)
                    case 1:
                        GoalConnectPage()
                    default:
                        HomeView(goals: $goals)
                    }
                    
                    BottomBar(
                        currentTab: $currentTab
                    )
                }
                .ignoresSafeArea(edges: .bottom)
            }
            
            
        }
    }
}

#Preview {
    ContentView()
}
