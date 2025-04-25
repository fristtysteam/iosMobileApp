import Foundation
import GRDB

@MainActor
class QuoteRepository: ObservableObject {
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    func createTable() throws {
        try dbQueue.write { db in
            try db.create(table: "quotes", ifNotExists: true) { t in
                t.column("quote", .text).notNull()
                t.column("author", .text).notNull()
                t.column("html", .text).notNull()
            }
        }
    }
    
    func saveQuote(_ quote: Quote) throws {
        try dbQueue.write { db in
            try quote.insert(db)
        }
    }
    
    func saveQuotes(_ quotes: [Quote]) throws {
        try dbQueue.write { db in
            for quote in quotes {
                try quote.insert(db)
            }
        }
    }
    
    func getQuotes() throws -> [Quote] {
        try dbQueue.read { db in
            try Quote.fetchAll(db)
        }
    }
    
    func getRandomQuote() throws -> Quote? {
        try dbQueue.read { db in
            try Quote.order(sql: "RANDOM()").fetchOne(db)
        }
    }
    
    func deleteAllQuotes() throws {
        try dbQueue.write { db in
            try Quote.deleteAll(db)
        }
    }
}
