import Foundation
import GRDB

final class DatabaseManager {
    static let shared = DatabaseManager()
    private var dbQueue: DatabaseQueue?
    
    // Set this to true to preserve database between app launches
    static let isDevelopment = true

    private init() {
        do {
            // Get the path to the app's documents directory and set the database name
            let databaseURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("appDatabase.sqlite")

            // Only delete the database if not in development mode
            if !DatabaseManager.isDevelopment {
                try? FileManager.default.removeItem(at: databaseURL)
            }

            // Database configuration and debugging SQL traces
            var configuration = Configuration()
            configuration.prepareDatabase { db in
                db.trace { print("SQL: \($0)") }
            }

            // Initialize the dbQueue with the configured path
            dbQueue = try DatabaseQueue(path: databaseURL.path, configuration: configuration)
            
            // Create tables and seed initial data if necessary
            try createTables()
            try seedInitialData()
        } catch {
            print("Database error: \(error)")
        }
    }

    // This function creates the necessary tables in the database
    private func createTables() throws {
        try dbQueue?.write { db in
            // User table (existing)
            try db.create(table: "user", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("username", .text).notNull().unique()
                t.column("email", .text).notNull()
                t.column("password", .text).notNull()
                t.column("profilePictureData", .blob)
            }

            // Add the badge table BEFORE user_badge
            try db.create(table: "badge", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("description", .text).notNull()
                t.column("imageName", .text).notNull()
                t.column("goalCountRequired", .integer).notNull()
            }

            // Goal table (existing)
            try db.create(table: "goal", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("title", .text).notNull()
                t.column("description", .text)
                t.column("category", .text)
                t.column("deadline", .date)
                t.column("isCompleted", .boolean).notNull().defaults(to: false)
                t.column("progress", .double).notNull().defaults(to: 0)
                t.column("userId", .text).notNull()
                t.column("progressDiary", .blob)
                t.foreignKey(["userId"], references: "user", onDelete: .cascade)
            }

            // UserBadge table - renamed to match model
            try db.create(table: "user_badge", ifNotExists: true) { t in
                t.column("userId", .text).notNull()
                t.column("badgeId", .text).notNull()
                t.column("dateEarned", .datetime).notNull()
                t.primaryKey(["userId", "badgeId"])
                t.foreignKey(["userId"], references: "user", onDelete: .cascade)
                t.foreignKey(["badgeId"], references: "badge", onDelete: .cascade)
            }

            // Quote table (existing)
            try db.create(table: "quote", ifNotExists: true) { t in
                t.column("quote", .text).notNull()
                t.column("author", .text).notNull()
                t.column("html", .text).notNull()
            }
        }
    }
    // This function seeds initial data like sample quotes if there are no users
    private func seedInitialData() throws {
        let userCount = try dbQueue?.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM user") ?? 0
        }
        let badgeCount = try dbQueue?.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM badge") ?? 0
            }


        guard userCount == 0 else { return }
        guard badgeCount == 0 else { return }
        
        let defaultBadges = [
                Badge(id: "beginner", name: "Beginner", description: "Completed 1 goal", imageName: "beginner", goalCountRequired: 1),
                Badge(id: "achiever", name: "Achiever", description: "Completed 5 goals", imageName: "achiever", goalCountRequired: 5),
                Badge(id: "expert", name: "Expert", description: "Completed 10 goals", imageName: "EXPERT", goalCountRequired: 10),
                Badge(id: "master", name: "Master", description: "Completed 25 goals", imageName: "master", goalCountRequired: 25),
                Badge(id: "legend", name: "Legend", description: "Completed 50 goals", imageName: "legend", goalCountRequired: 50)
            ]
            
            try dbQueue?.write { db in
                for badge in defaultBadges {
                    try badge.insert(db)
                }
                print("✅ Seeded \(defaultBadges.count) badges")
            }


        // Create a test user
        let testUser = User(
            id: UUID(),
            username: "testuser",
            email: "test@example.com",
            password: "password",
            goals: []
        )
        
        // Insert test user
        try dbQueue?.write { db in
            try testUser.insert(db)
            print("✅ Created test user: \(testUser.username)")
            
            // Create sample goals for the test user
            let sampleGoals = [
                Goal(
                    id: UUID(),
                    userId: testUser.id,
                    title: "Learn SwiftUI",
                    description: "Master SwiftUI framework for iOS development",
                    category: "Learning",
                    deadline: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                    progress: 0.3,
                    isCompleted: false,
                    progressDiary: ["Started with basic UI components", "Completed navigation tutorial"]
                ),
                Goal(
                    id: UUID(),
                    userId: testUser.id,
                    title: "Exercise Routine",
                    description: "Maintain a consistent workout schedule",
                    category: "Health",
                    deadline: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
                    progress: 0.6,
                    isCompleted: false,
                    progressDiary: ["Started morning runs", "Added strength training"]
                ),
                Goal(
                    id: UUID(),
                    userId: testUser.id,
                    title: "Read 12 Books",
                    description: "Read one book per month for personal growth",
                    category: "Personal",
                    deadline: Calendar.current.date(byAdding: .year, value: 1, to: Date()),
                    progress: 0.25,
                    isCompleted: false,
                    progressDiary: ["Finished 'Atomic Habits'", "Started 'Deep Work'"]
                )
            ]
            
            // Insert sample goals
            for goal in sampleGoals {
                try goal.insert(db)
            }
            print("✅ Created \(sampleGoals.count) sample goals for test user")
        }

        // Seed with some sample quotes
        let sampleQuotes = [
            Quote(quote: "The journey of a thousand miles begins with one step.", author: "Lao Tzu", html: ""),
            Quote(quote: "That which does not kill us makes us stronger.", author: "Friedrich Nietzsche", html: ""),
            Quote(quote: "Are you the code or the coded?", author: "Marco Ladeira", html: "")
        ]

        // Insert sample quotes into the database
        try dbQueue?.write { db in
            for quote in sampleQuotes {
                try quote.insert(db)
            }
            print("✅ Seeded \(sampleQuotes.count) quotes")
        }
        
        
        
    }

    // Returns the shared database queue instance
    func getDatabase() -> DatabaseQueue {
        guard let dbQueue = dbQueue else {
            fatalError("Database not initialized")
        }
        return dbQueue
    }

    // Prints the database path for debugging purposes
    func printDatabasePath() {
        let path = try! FileManager.default
            .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("appDatabase.sqlite").path
        print("📂 Database path: \(path)")
    }
}
