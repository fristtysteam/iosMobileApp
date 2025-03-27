import Foundation

struct User: Identifiable, Codable {
    var id: UUID
    var username: String
    var email: String
    var password: String // Added password field
    var goals: [Goal]
    
    init(id: UUID = UUID(), username: String, email: String, password: String, goals: [Goal] = []) {
        self.id = id
        self.username = username
        self.email = email
        self.password = password
        self.goals = goals
    }
}
