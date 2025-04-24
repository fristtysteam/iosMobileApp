import SwiftUI

@main
struct IosMobileAppApp: App {
    
    private let databaseManager = DatabaseManager.shared
    private let userRepository: UserRepository
    private let goalRepository: GoalRepository
    private let quoteRepository: QuoteRepository
    private let badgeRepository: BadgeRepository
    private let authController: AuthController
    private let goalController: GoalController
    private let userController: UserController
    private let badgeController: BadgeController
    @StateObject private var themeManager = ThemeManager()
    
    #if DEBUG
    // Development mode will always show ContentView with test data
    private let isDevelopmentMode = false
    private let testUserId = UUID()
    @State private var isFirstLaunch = true
    #endif
    
    // Initialize everything
    init() {
        let dbQueue = databaseManager.getDatabase()
        
        // Initialize repositories first
        self.userRepository = UserRepository(dbQueue: dbQueue)
        self.goalRepository = GoalRepository(dbQueue: dbQueue)
        self.quoteRepository = QuoteRepository(dbQueue: dbQueue)
        self.badgeRepository = BadgeRepository(dbQueue: dbQueue)
        
        // Initialize controllers after repositories
        self.authController = AuthController(userRepository: userRepository, goalRepository: goalRepository)
        self.badgeController = BadgeController(badgeRepository: badgeRepository, userRepository: userRepository)
        self.goalController = GoalController(
            goalRepository: goalRepository,
            authController: authController,
            badgeController: badgeController
        )
        self.userController = UserController(userRepository: userRepository, authController: authController)
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
                    .environmentObject(badgeController)
                    .preferredColorScheme(themeManager.colorScheme)
                    .task {
                        if isFirstLaunch {
                            isFirstLaunch = false
                            await setupTestData()
                        }
                        // Initialize badges after view appears
                        try? await badgeRepository.initializeBadges()
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
                    .environmentObject(badgeController)
                    .preferredColorScheme(themeManager.colorScheme)
                    .task {
                        // Initialize badges after view appears
                        try? await badgeRepository.initializeBadges()
                    }
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
                .environmentObject(badgeController)
                .preferredColorScheme(themeManager.colorScheme)
                .task {
                    // Initialize badges after view appears
                    try? await badgeRepository.initializeBadges()
                }
            #endif
        }
    }
}
