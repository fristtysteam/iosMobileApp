import Foundation
import GRDB
import Combine

@MainActor
class UserRepository: ObservableObject {
    private let database: DatabaseQueue
    @Published var users: [User] = []
    
    init(dbQueue: DatabaseQueue) {
        self.database = dbQueue
        Task {
            await loadUsers()
        }
    }
    
    private func loadUsers() async {
        do {
            users = try await database.read { db in
                try User.fetchAll(db)
            }
        } catch {
            print("Error loading users: \(error)")
        }
    }
    
    func login(username: String, password: String) async throws -> User {
        print("Attempting login for username: \(username)")
        
        do {
            let user = try await database.read { db in
                try User
                    .filter(Column("username") == username && Column("password") == password)
                    .fetchOne(db)
            }
            
            if let user = user {
                print("Login successful for user: \(user.username)")
                return user
            } else {
                print("No user found with provided credentials")
                throw AuthError.invalidCredentials
            }
        } catch {
            print("Database error during login: \(error)")
            throw error
        }
    }
    
    func register(username: String, email: String, password: String) async throws -> User {
        print("Attempting registration for username: \(username)")
        
        // Check if username already exists
        let existingUser = try await database.read { db in
            try User
                .filter(Column("username") == username)
                .fetchOne(db)
        }
        
        if existingUser != nil {
            print("Username already exists: \(username)")
            throw AuthError.usernameTaken
        }
        
        // Create new user with a new UUID
        let user = User(
            id: UUID(),
            username: username,
            email: email,
            password: password,
            goals: []
        )
        
        try await database.write { db in
            try user.insert(db)
        }
        
        print("Successfully registered user: \(username)")
        return user
    }
    
    func verifyPassword(userId: UUID, password: String) async throws -> Bool {
        return try await database.read { db in
            let user = try User.fetchOne(db, sql: "SELECT * FROM user WHERE id = ?", arguments: [userId.uuidString])
            return user?.password == password
        }
    }
    
    func getAllUsers() async throws -> [User] {
        return try await database.read { db in
            try User.fetchAll(db)
        }
    }
    
    func isUsernameTaken(_ username: String) async throws -> Bool {
        return try await database.read { db in
            let count = try User.filter(Column("username") == username).fetchCount(db)
            return count > 0
        }
    }
    
    func updateUser(
        userID: UUID,
        newUsername: String,
        newEmail: String,
        currentPassword: String,
        newPassword: String? = nil,
        profilePictureData: Data? = nil
    ) async throws -> User {
        return try await database.write { db in
            // Check if username is taken by another user
            if try User.filter(Column("username") == newUsername)
                .filter(Column("id") != userID.uuidString)
                .fetchCount(db) > 0 {
                throw AuthError.usernameTaken
            }
            
            // Get current user
            guard let currentUser = try User.fetchOne(db, key: userID.uuidString) else {
                throw AuthError.userNotFound
            }
            
            // Verify current password
            guard currentUser.password == currentPassword else {
                throw AuthError.invalidPassword
            }
            
            // Create updated user object
            var updatedUser = User(
                id: userID,
                username: newUsername,
                email: newEmail,
                password: newPassword ?? currentUser.password,
                goals: currentUser.goals,
                profilePictureData: profilePictureData ?? currentUser.profilePictureData
            )
            
            // Update the user in the database
            try updatedUser.update(db)
            
            // Return the updated user
            return updatedUser
        }
    }
    
    // Add a dedicated method for updating profile picture only
    func updateProfilePicture(userID: UUID, profilePictureData: Data?) async throws -> User {
        return try await database.write { db in
            // Get current user
            guard let currentUser = try User.fetchOne(db, key: userID.uuidString) else {
                throw AuthError.userNotFound
            }
            
            // Create updated user object with just the profile picture changed
            var updatedUser = User(
                id: userID,
                username: currentUser.username,
                email: currentUser.email,
                password: currentUser.password,
                goals: currentUser.goals,
                profilePictureData: profilePictureData
            )
            
            // Update the user in the database
            try updatedUser.update(db)
            
            // Return the updated user
            return updatedUser
        }
    }
    
    // Add method to update profile info without password verification
    func updateProfileInfo(
        userID: UUID,
        newUsername: String,
        newEmail: String,
        profilePictureData: Data?
    ) async throws -> User {
        return try await database.write { db in
            // Check if username is taken by another user
            if try User.filter(Column("username") == newUsername)
                .filter(Column("id") != userID.uuidString)
                .fetchCount(db) > 0 {
                throw AuthError.usernameTaken
            }
            
            // Get current user
            guard let currentUser = try User.fetchOne(db, key: userID.uuidString) else {
                throw AuthError.userNotFound
            }
            
            // Create updated user object
            var updatedUser = User(
                id: userID,
                username: newUsername,
                email: newEmail,
                password: currentUser.password, // Keep the existing password
                goals: currentUser.goals,
                profilePictureData: profilePictureData ?? currentUser.profilePictureData
            )
            
            // Update the user in the database
            try updatedUser.update(db)
            
            // Return the updated user
            return updatedUser
        }
    }
    
    func deleteAllUsers() async throws {
        try await database.write { db in
            try User.deleteAll(db)
        }
    }
    
    // Add method to get user by ID
    func getUserById(_ userId: UUID) async throws -> User? {
        return try await database.read { db in
            try User.fetchOne(db, key: userId.uuidString)
        }
    }
    func getUserWithBadges(userId: UUID) async throws -> User {
        return try await database.read { db in
            guard var user = try User.fetchOne(db, key: userId.uuidString) else {
                throw AuthError.userNotFound
            }

            let badges = try Badge
                .filter(sql: """
                    id IN (
                        SELECT badgeId FROM user_badge WHERE userId = ?
                    )
                """, arguments: [userId.uuidString])
                .fetchAll(db)

          
            return user
        }
    }


    func getCompletedGoalsCount(userId: UUID) async throws -> Int {
        return try await database.read { db in
            try Goal
                .filter(Column("userId") == userId.uuidString)
                .filter(Column("isCompleted") == true)
                .fetchCount(db)
        }
    }
    
    
}
