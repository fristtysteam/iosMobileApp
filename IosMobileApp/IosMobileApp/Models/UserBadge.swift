//
//  UserBadge.swift
//  IosMobileApp
//
//  Created by Student on 24/04/2025.
//

import Foundation
import GRDB

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
    static let badge = belongsTo(Badge.self)  // Make sure the association is here
}
