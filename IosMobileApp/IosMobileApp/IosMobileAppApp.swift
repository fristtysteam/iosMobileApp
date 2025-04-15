import SwiftUI

@main
struct IosMobileAppApp: App {
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
        
        // You could also print or handle errors if necessary
        // For example:
        // databaseManager.printDatabasePath()
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
