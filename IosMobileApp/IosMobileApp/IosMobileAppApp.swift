import SwiftUI

@main
struct IosMobileAppApp: App {
    
    private let databaseManager = DatabaseManager.shared
    private let userRepository: UserRepository
    private let goalRepository: GoalRepository
    private let quoteRepository: QuoteRepository
    private let authController: AuthController
    private let goalController: GoalController
    private let userController: UserController
    @StateObject private var themeManager = ThemeManager()
    
    #if DEBUG
    // Development mode will always show ContentView with test data
    private let isDevelopmentMode = false
    private let testUserId = UUID()
    @State private var isFirstLaunch = true
    @State private var showSplash = true

    #endif
    
    // Initialize everything
    // Update the init in your App struct
    init() {
        let dbQueue = databaseManager.getDatabase()
        userRepository = UserRepository(dbQueue: dbQueue)
        goalRepository = GoalRepository(dbQueue: dbQueue)
        quoteRepository = QuoteRepository(dbQueue: dbQueue)
        let badgeRepository = BadgeRepository(dbQueue: dbQueue)
        
        // Initialize badges if needed
        Task {
            try await badgeRepository.initializeBadges()
        }
        
        authController = AuthController(userRepository: userRepository, goalRepository: goalRepository)
        goalController = GoalController(
            goalRepository: goalRepository,
            authController: authController,
            badgeRepository: badgeRepository,
            userRepository: userRepository
        )
        userController = UserController(userRepository: userRepository, authController: authController)
    }
    
    #if DEBUG
    private func setupTestData() async {
        // Create a test user
        let testUser = User(
            id: testUserId,
            username: "test",
            email: "test@example.com",
            password: "pass"
        )
        
        // Try to register the test user
        do {
            _ = try await userRepository.register(
                username: testUser.username,
                email: testUser.email,
                password: testUser.password
            )
            
            // Create some test goals
            let testGoals = [
                Goal(
                    id: UUID(),
                    userId: testUserId,
                    title: "Learn SwiftUI",
                    description: "Master SwiftUI fundamentals",
                    category: "Learning",
                    deadline: Date().addingTimeInterval(7*24*60*60),
                    progress: 0.3,
                    isCompleted: false
                ),
                Goal(
                    id: UUID(),
                    userId: testUserId,
                    title: "Build Demo App",
                    description: "Create a fully functional demo application",
                    category: "Development",
                    deadline: Date().addingTimeInterval(14*24*60*60),
                    progress: 0.0,
                    isCompleted: false
                ),
                Goal(
                    id: UUID(),
                    userId: testUserId,
                    title: "Write Documentation",
                    description: "Document all key features",
                    category: "Documentation",
                    deadline: Date().addingTimeInterval(3*24*60*60),
                    progress: 1.0,
                    isCompleted: true
                )
            ]
            
            // Add the goals
            for goal in testGoals {
                try goalRepository.saveGoal(goal)
            }
            
            // Try to login with the test user
            _ = try await userRepository.login(username: testUser.username, password: testUser.password)
            
        } catch {
            print("Error setting up test data: \(error)")
        }
    }
    #endif
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreen()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                #if DEBUG
                if isDevelopmentMode {
                    ContentView()
                        .environmentObject(authController)
                        .environmentObject(userRepository)
                        .environmentObject(goalRepository)
                        .environmentObject(quoteRepository)
                        .environmentObject(goalController)
                        .environmentObject(userController)
                        .environmentObject(themeManager)
                        .preferredColorScheme(themeManager.colorScheme)
                        .task {
                            if isFirstLaunch {
                                isFirstLaunch = false
                                await setupTestData()
                            }
                        }
                } else {
                    AuthView()
                        .environmentObject(authController)
                        .environmentObject(userRepository)
                        .environmentObject(goalRepository)
                        .environmentObject(quoteRepository)
                        .environmentObject(goalController)
                        .environmentObject(userController)
                        .environmentObject(themeManager)
                        .preferredColorScheme(themeManager.colorScheme)
                }
                #else
                ContentView()
                    .environmentObject(authController)
                    .environmentObject(userRepository)
                    .environmentObject(goalRepository)
                    .environmentObject(quoteRepository)
                    .environmentObject(goalController)
                    .environmentObject(userController)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.colorScheme)
                #endif
            }
        }

    }
}
