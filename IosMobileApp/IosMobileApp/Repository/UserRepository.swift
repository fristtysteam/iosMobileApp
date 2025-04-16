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
    
    func updateUser(userId: UUID, username: String, email: String, newPassword: String?) async throws {
        try await database.write { db in
            // Check if username is taken by another user
            if try User.filter(Column("username") == username)
                .filter(Column("id") != userId.uuidString)
                .fetchCount(db) > 0 {
                throw AuthError.usernameTaken
            }
            
            // Get current user
            guard let currentUser = try User.fetchOne(db, key: userId.uuidString) else {
                throw AuthError.invalidCredentials
            }
            
            // Update user
            var updatedUser = User(
                id: userId,
                username: username,
                email: email,
                password: newPassword ?? currentUser.password
            )
            
            try updatedUser.update(db)
        }
    }
    
    func deleteAllUsers() async throws {
        try await database.write { db in
            try User.deleteAll(db)
        }
    }
} 