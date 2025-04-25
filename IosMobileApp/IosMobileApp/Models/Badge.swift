//
//  Badge.swift
//  IosMobileApp
//
//  Created by Student on 22/04/2025.
//

import Foundation
import GRDB

struct Badge: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: String
    let name: String
    let description: String
    let imageName: String
    let goalCountRequired: Int
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
        static let imageName = Column(CodingKeys.imageName)
        static let goalCountRequired = Column(CodingKeys.goalCountRequired)
    }
    
    static let allBadges: [Badge] = [
        Badge(id: "beginner", name: "Beginner", description: "Completed 1 goal", imageName: "beginner", goalCountRequired: 1),
        Badge(id: "achiever", name: "Achiever", description: "Completed 5 goals", imageName: "achiever", goalCountRequired: 5),
        Badge(id: "expert", name: "Expert", description: "Completed 10 goals", imageName: "EXPERT", goalCountRequired: 10),
        Badge(id: "master", name: "Master", description: "Completed 25 goals", imageName: "master", goalCountRequired: 25),
        Badge(id: "legend", name: "Legend", description: "Completed 50 goals", imageName: "legend", goalCountRequired: 50)
    ]
}

struct UserBadge: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: String { "\(userId)-\(badgeId)" }
    let userId: UUID
    let badgeId: String
    let dateEarned: Date
    
    static let databaseTableName = "user_badge"
    
    enum Columns {
        static let userId = Column(CodingKeys.userId)
        static let badgeId = Column(CodingKeys.badgeId)
        static let dateEarned = Column(CodingKeys.dateEarned)
    }
    
    init(userId: UUID, badgeId: String, dateEarned: Date = Date()) {
        self.userId = userId
        self.badgeId = badgeId
        self.dateEarned = dateEarned
    }
    
    func encode(to container: inout PersistenceContainer) {
        container["userId"] = userId.uuidString
        container["badgeId"] = badgeId
        container["dateEarned"] = dateEarned
    }
    
    init(row: Row) throws {
        userId = UUID(uuidString: row["userId"])!
        badgeId = row["badgeId"]
        dateEarned = row["dateEarned"]
    }
}
