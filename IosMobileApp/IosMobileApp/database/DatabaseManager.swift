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

            // UserBadge table
            try db.create(table: "userBadge", ifNotExists: true) { t in
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
            Badge(id: "beginner", name: "Beginner", description: "Completed 1 goal", imageName: "badge.beginner", goalCountRequired: 1),
            Badge(id: "achiever", name: "Achiever", description: "Completed 5 goals", imageName: "badge.achiever", goalCountRequired: 5),
            Badge(id: "expert", name: "Expert", description: "Completed 10 goals", imageName: "badge.expert", goalCountRequired: 10),
            Badge(id: "master", name: "Master", description: "Completed 25 goals", imageName: "badge.master", goalCountRequired: 25),
            Badge(id: "legend", name: "Legend", description: "Completed 50 goals", imageName: "badge.legend", goalCountRequired: 50)
        ]
        
        try dbQueue?.write { db in
            for badge in defaultBadges {
                try badge.insert(db)
            }
            print("✅ Seeded \(defaultBadges.count) badges")
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
