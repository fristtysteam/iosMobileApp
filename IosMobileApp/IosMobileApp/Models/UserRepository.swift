//
//  UserRepository.swift
//  IosMobileApp
//
//  Created by Student on 14/04/2025.
//

import GRDB
import Foundation
class UserRepository: ObservableObject {
    private let dbQueue: DatabaseQueue
    
    init(dbQueue: DatabaseQueue) {
        self.dbQueue = dbQueue
    }
    
    // Create or update a user
    func saveUser(_ user: User) throws {
        try dbQueue.write { db in
            try user.save(db)
        }
    }
    
    // Fetch user by ID
    func getUser(id: UUID) throws -> User? {
        try dbQueue.read { db in
            try User.fetchOne(db, key: id.uuidString)
        }
    }
    
    // Fetch user by email
    func getUserByEmail(_ email: String) throws -> User? {
        try dbQueue.read { db in
            try User.filter(User.Columns.email == email).fetchOne(db)
        }
    }
    
    // Delete user
    func deleteUser(_ user: User) throws {
        try dbQueue.write { db in
            try user.delete(db)
        }
    }
}
