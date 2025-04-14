//
//  QuoteRepository.swift
//  IosMobileApp
//
//  Created by Student on 14/04/2025.
//


import GRDB
import Foundation
class QuoteRepository: ObservableObject {
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    // Fetch random quote
    func getRandomQuote() throws -> Quote? {
        try dbQueue.read { db in
            try Quote.order(sql: "RANDOM()").fetchOne(db)
        }
    }
    
    // Save multiple quotes
    func saveQuotes(_ quotes: [Quote]) throws {
        try dbQueue.write { db in
            for quote in quotes {
                try quote.save(db)
            }
        }
    }
}
