import SwiftUI

@main
struct IosMobileAppApp: App {
    
    private let databaseManager = DatabaseManager.shared
    private let userRepository: UserRepository
    private let goalRepository: GoalRepository
    private let quoteRepository: QuoteRepository
    private let userController = UserController()
    private let goalController: GoalController
    
    // Development flag to toggle between AuthView and ContentView
    #if DEBUG
    @AppStorage("showAuthView") private var showAuthView = true
    #endif
    
    // Initialize everything
    init() {
        let dbQueue = databaseManager.getDatabase()
        userRepository = UserRepository(dbQueue: dbQueue)
        goalRepository = GoalRepository(dbQueue: dbQueue)
        quoteRepository = QuoteRepository(dbQueue: dbQueue)
        goalController = GoalController(goalRepository: goalRepository)
        
        // You could also print or handle errors if necessary
        // For example:
        // databaseManager.printDatabasePath()
    }
    
    var body: some Scene {
        WindowGroup {
            #if DEBUG
            Group {
                if showAuthView {
                    AuthView()
                        .environmentObject(userController)
                        .environmentObject(userRepository)
                        .environmentObject(goalRepository)
                        .environmentObject(quoteRepository)
                        .environmentObject(goalController)
                } else {
                    ContentView()
                        .environmentObject(userController)
                        .environmentObject(userRepository)
                        .environmentObject(goalRepository)
                        .environmentObject(quoteRepository)
                        .environmentObject(goalController)
                }
            }
            .overlay(
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { showAuthView.toggle() }) {
                            Text(showAuthView ? "Switch to Main App" : "Switch to Auth")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            )
            #else
            ContentView()
                .environmentObject(userController)
                .environmentObject(userRepository)
                .environmentObject(goalRepository)
                .environmentObject(quoteRepository)
                .environmentObject(goalController)
            #endif
        }
    }
}
