import Foundation
import GRDB

struct Goal: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: UUID
    var userId: UUID
    var title: String
    var description: String?
    var category: String?
    var deadline: Date?
    var progress: Double
    var isCompleted: Bool
    var progressDiary: [String]
    
    init(id: UUID = UUID(), userId: UUID, title: String, description: String? = nil, category: String? = nil, deadline: Date? = nil, progress: Double = 0.0, isCompleted: Bool = false, progressDiary: [String] = []) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.category = category
        self.deadline = deadline
        self.progress = progress
        self.isCompleted = isCompleted
        self.progressDiary = progressDiary
    }
    
    // Encode for database
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id.uuidString
        container["userId"] = userId.uuidString
        container["title"] = title
        container["description"] = description
        container["category"] = category
        container["deadline"] = deadline
        container["progress"] = progress
        container["isCompleted"] = isCompleted
        
        // Encode progressDiary array to JSON data
        if let jsonData = try? JSONEncoder().encode(progressDiary) {
            container["progressDiary"] = jsonData
        }
    }
    
    // Decode from database
    init(row: Row) throws {
        id = UUID(uuidString: row["id"]) ?? UUID()
        userId = UUID(uuidString: row["userId"]) ?? UUID()
        title = row["title"]
        description = row["description"]
        category = row["category"]
        deadline = row["deadline"]
        progress = row["progress"]
        isCompleted = row["isCompleted"]
        
        // Decode progressDiary from JSON data
        if let jsonData = row["progressDiary"] as? Data,
           let diary = try? JSONDecoder().decode([String].self, from: jsonData) {
            progressDiary = diary
        } else {
            progressDiary = []
        }
    }
}
