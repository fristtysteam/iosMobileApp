import SwiftUI

@main
struct IosMobileAppApp: App {
    @StateObject private var appState = AppState()

    var body: some View {
        // Add your view hierarchy here
        Text("Hello, World!")
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
            // Register the test user and wait for it to complete
            let registeredUser = try await userRepository.register(
                username: testUser.username,
                email: testUser.email,
                password: testUser.password
            )
            
            // Verify the user was registered successfully
            guard let _ = try await userRepository.getUserById(registeredUser.id) else {
                print("Error: Test user registration failed - user not found in database")
                return
            }
            
            // Create some test goals
            let testGoals = [
                Goal(
                    id: UUID(),
                    userId: registeredUser.id, // Use the registered user's ID
                    title: "Learn SwiftUI",
                    description: "Master SwiftUI fundamentals",
                    category: "Learning",
                    deadline: Date().addingTimeInterval(7*24*60*60),
                    progress: 0.3,
                    isCompleted: false
                ),
                Goal(
                    id: UUID(),
                    userId: registeredUser.id, // Use the registered user's ID
                    title: "Build Demo App",
                    description: "Create a fully functional demo application",
                    category: "Development",
                    deadline: Date().addingTimeInterval(14*24*60*60),
                    progress: 0.0,
                    isCompleted: false
                ),
                Goal(
                    id: UUID(),
                    userId: registeredUser.id, // Use the registered user's ID
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
}

struct IosMobileAppApp_Previews: PreviewProvider {
    static var previews: some View {
        IosMobileAppApp()
    }
} 