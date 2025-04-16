import SwiftUI

@main
struct IosMobileAppApp: App {
    
    private let databaseManager = DatabaseManager.shared
    private let userRepository: UserRepository
    private let goalRepository: GoalRepository
    private let quoteRepository: QuoteRepository
    private let authController: AuthController
    private let goalController: GoalController
    
    #if DEBUG
    // Development mode will always show ContentView with test data
    private let isDevelopmentMode = true
    private let testUserId = UUID()
    @State private var isFirstLaunch = true
    #endif
    
    // Initialize everything
    init() {
        let dbQueue = databaseManager.getDatabase()
        userRepository = UserRepository(dbQueue: dbQueue)
        goalRepository = GoalRepository(dbQueue: dbQueue)
        quoteRepository = QuoteRepository(dbQueue: dbQueue)
        authController = AuthController(userRepository: userRepository)
        goalController = GoalController(goalRepository: goalRepository, authController: authController)
    }
    
    #if DEBUG
    private func setupTestData() async {
        // Create a test user
        let testUser = User(
            id: testUserId,
            username: "TestUser",
            email: "test@example.com",
            password: "testpassword123"
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
            }
            #else
            ContentView()
                .environmentObject(authController)
                .environmentObject(userRepository)
                .environmentObject(goalRepository)
                .environmentObject(quoteRepository)
                .environmentObject(goalController)
            #endif
        }
    }
}
