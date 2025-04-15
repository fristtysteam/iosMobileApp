import Foundation
import GRDB

final class DatabaseManager {
    static let shared = DatabaseManager()
    private var dbQueue: DatabaseQueue?

    private init() {
        do {
            // Get the path to the app's documents directory and set the database name
            let databaseURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("appDatabase.sqlite")

            // Optional: Delete the old DB during development if needed
            // try? FileManager.default.removeItem(at: databaseURL)

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
            // User table
            try db.create(table: "user", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("username", .text).notNull()
                t.column("email", .text).notNull()
                t.column("password", .text).notNull()
            }

            // Goal table
            try db.create(table: "goal", ifNotExists: true) { t in
                t.column("id", .text).primaryKey()
                t.column("userId", .text).references("user", onDelete: .cascade)
                t.column("title", .text).notNull()
                t.column("description", .text)
                t.column("category", .text)
                t.column("deadline", .datetime)
                t.column("progress", .double).notNull().defaults(to: 0.0)
                t.column("isCompleted", .boolean).notNull().defaults(to: false)
                t.column("progressDiary", .blob).notNull() // Store progress as JSON
            }

            // Quote table
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

        guard userCount == 0 else { return }

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
