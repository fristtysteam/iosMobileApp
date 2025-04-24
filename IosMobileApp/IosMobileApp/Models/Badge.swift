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
    
    static let databaseTableName = "badge"
    static let userBadges = hasMany(UserBadge.self)

    enum Columns {
        static let id = Column(CodingKeys.id)
        static let name = Column(CodingKeys.name)
        static let description = Column(CodingKeys.description)
        static let imageName = Column(CodingKeys.imageName)
        static let goalCountRequired = Column(CodingKeys.goalCountRequired)
    }

    static let allBadges: [Badge] = [
          Badge(id: "beginner", name: "Beginner", description: "Completed 1 goal", imageName: "badge.beginner", goalCountRequired: 1),
          Badge(id: "achiever", name: "Achiever", description: "Completed 5 goals", imageName: "badge.achiever", goalCountRequired: 5),
          Badge(id: "expert", name: "Expert", description: "Completed 10 goals", imageName: "badge.expert", goalCountRequired: 10),
          Badge(id: "master", name: "Master", description: "Completed 25 goals", imageName: "badge.master", goalCountRequired: 25),
          Badge(id: "legend", name: "Legend", description: "Completed 50 goals", imageName: "badge.legend", goalCountRequired: 50)
      ]
  }

extension Badge {
    static let userBadges = hasMany(UserBadge.self) 
}

struct UserBadge: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: String { "\(userId)-\(badgeId)" }
    let userId: UUID
    let badgeId: String
    let dateEarned: Date

    var badge: Badge!

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
}

extension UserBadge {
    static let badge = belongsTo(Badge.self)
}
