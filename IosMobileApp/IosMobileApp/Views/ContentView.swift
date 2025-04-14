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

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HeaderView(title: "Achievr")

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Goals")
                                .font(.title)
                                .bold()

                            CustomPagingSlider(data: $goals) { goal in
                                GoalCardView(title: goal.wrappedValue.title,
                                             description: goal.wrappedValue.description,
                                             progress: goal.wrappedValue.progress,
                                             category: goal.wrappedValue.category,
                                             deadline: goal.wrappedValue.deadline)
                            }
                        }

                        VStack(alignment: .center, spacing: 10) {
                            Text("Quote Of The Day")
                                .font(.title)
                                .italic()
                                .frame(maxWidth: .infinity)

                            if isLoadingQuote {
                                ProgressView("Fetching quote...")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else if let quote = quote {
                                HStack(alignment: .top) {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .padding(.top, 10)

                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.blue)
                                            .padding(.leading, 5)

                                        Text(quote.quote)
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                }
                            }
                        }
                        .task {
                            isLoadingQuote = true
                            do {
                                let res = try await performQuotesApiCall()
                                quote = res
                            } catch {
                                print("Error: \(error)")
                            }
                            isLoadingQuote = false
                        }
                    }
                    .padding(.bottom, 80)
                    .padding(.horizontal)
                }

                BottomBar(
                    selectedTab: $selectedTab,
                    homeAction: { },
                    goalsAction: { navigationPath.append(TabDestination.goals) },
                    profileAction: { navigationPath.append(TabDestination.profile) },
                    settingsAction: { navigationPath.append(TabDestination.settings) },
                    helpAction: { navigationPath.append(TabDestination.help) },
                    logoutAction: { navigationPath.append(TabDestination.logout) }
                )
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(for: TabDestination.self) { destination in
                switch destination {
                case .home:
                    ContentView()
                case .goals:
                    GoalConnectPage()
                case .profile:
                    ProfileSettingsView()
                case .settings:
                    GoalConnectPage()
                case .help:
                    GoalConnectPage()
                case .logout:
                    GoalConnectPage()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
