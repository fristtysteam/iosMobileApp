import SwiftUI

@main
struct IosMobileAppApp: App {
    @StateObject private var userController = UserController()
    private let databaseManager = DatabaseManager.shared
    
    private let userRepository: UserRepository
    private let goalRepository: GoalRepository
    private let quoteRepository: QuoteRepository
    
    // Initialize everything
    init() {
        let dbQueue = databaseManager.getDatabase()
        
        userRepository = UserRepository(dbQueue: dbQueue)
        goalRepository = GoalRepository(dbQueue: dbQueue)
        quoteRepository = QuoteRepository(dbQueue: dbQueue)
        
       
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userRepository)
                .environmentObject(goalRepository)
                .environmentObject(quoteRepository)
        }
    }
}
