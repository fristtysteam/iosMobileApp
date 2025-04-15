import Foundation
import GRDB

struct User: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: UUID
    var username: String
    var email: String
    var password: String
    var goals: [Goal] = [] 

    
    init(id: UUID = UUID(), username: String, email: String, password: String, goals: [Goal] = []) {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.goals = goals
    }
    
    // Database column names
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let username = Column(CodingKeys.username)
        static let email = Column(CodingKeys.email)
        static let password = Column(CodingKeys.password)
    }
    
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id.uuidString
        container["username"] = username
        container["email"] = email
        container["password"] = password
    }
    
    init(row: Row) throws {
        id = UUID(uuidString: row["id"]) ?? UUID()
        username = row["username"]
        email = row["email"]
        password = row["password"]
    }
}
