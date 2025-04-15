//
//  DatabaseManager.swift
//  IosMobileApp
//
//  Created by Student on 14/04/2025.
//

import Foundation
import GRDB

final class DatabaseManager {
    static let shared = DatabaseManager()
    private var dbQueue: DatabaseQueue?
    
    
    private init() {
        do{
            let databaseURL = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("appDatabase.sqlite")
            
            //confugure db
            var configuration = Configuration()
            configuration.prepareDatabase { db in
                db.trace { print("SQL: \($0)") }
            }
            
            dbQueue = try DatabaseQueue(path: databaseURL.path, configuration: configuration)
            try createTables()
            try seedInitialData()
        } catch {
            print("Database error: \(error)")
        }
    }
    
    private func createTables() throws {
        try dbQueue?.write { db in
            //user table
            try db.create(table: "user") { t in
                t.column("id", .text).primaryKey()
                t.column("username", .text).notNull()
                t.column("email", .text).notNull()
                t.column("password", .text).notNull()
            }
            
            //goal table
            try db.create(table: "goal") { t in
                t.column("id", .text).primaryKey()
                t.column("userId", .text).references("user", onDelete: .cascade)
                t.column("title", .text).notNull()
                t.column("description", .text)
                t.column("category", .text)
                t.column("deadline", .datetime)
                t.column("progress", .double).notNull().defaults(to: 0.0)
                t.column("isCompleted", .boolean).notNull().defaults(to: false)
                t.column("progressDiary", .blob).notNull() //store as json
            }
            // Quote table
            try db.create(table: "quote") { t in
                t.column("quote", .text).notNull()
                t.column("author", .text).notNull()
                t.column("html", .text).notNull()
            }
        }
    }
    
            
            
            
    private func seedInitialData() throws {
            //check if we already have data
            let userCount = try dbQueue?.read { db in
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM user") ?? 0
            }
            
            guard userCount == 0 else { return }
            
            // sample quotes
            let sampleQuotes = [
                Quote(quote: "The journey of a thousand miles begins with one step.", author: "Lao Tzu", html: ""),
                Quote(quote: "That which does not kill us makes us stronger.", author: "Friedrich Nietzsche", html: ""),
                Quote(quote: "are you the code or the coded", author: "Marco Ladeira", html: "")
            ]
            
            try dbQueue?.write { db in
                for quote in sampleQuotes {
                    try quote.insert(db)
                }
            }
        }
        
        func getDatabase() -> DatabaseQueue {
            guard let dbQueue = dbQueue else {
                fatalError("Database not initialized")
            }
            return dbQueue
        }
    }
