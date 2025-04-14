import Foundation
import GRDB


struct Goal: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: UUID
    var userId: UUID?
    var title: String
    var description: String?
    var category: String?
    var deadline: Date?
    var progress: Double
    var isCompleted: Bool
    var progressDiary: [String]
    
    init(id: UUID = UUID(), title: String, description: String? = nil, category: String? = nil,
         deadline: Date? = nil, progress: Double = 0.0, isCompleted: Bool = false,
         progressDiary: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.deadline = deadline
        self.progress = progress
        self.isCompleted = isCompleted
        self.progressDiary = progressDiary
    }
    
    enum Columns {
        static let id = Column(CodingKeys.id)
        static let userId = Column(CodingKeys.userId)
        static let title = Column(CodingKeys.title)
        static let description = Column(CodingKeys.description)
        static let category = Column(CodingKeys.category)
        static let deadline = Column(CodingKeys.deadline)
        static let progress = Column(CodingKeys.progress)
        static let isCompleted = Column(CodingKeys.isCompleted)
        static let progressDiary = Column(CodingKeys.progressDiary)
    }
    
    func encode(to container: inout PersistenceContainer) {
        container["id"] = id.uuidString
        container["userId"] = userId?.uuidString
        container["title"] = title
        container["description"] = description
        container["category"] = category
        container["deadline"] = deadline
        container["progress"] = progress
        container["isCompleted"] = isCompleted
        
        // Convert progressDiary array to JSON data
        if let data = try? JSONEncoder().encode(progressDiary) {
            container["progressDiary"] = data
        }
    }
    
    init(row: Row) throws {
        id = UUID(uuidString: row["id"]) ?? UUID()
        if let userIdString = row["userId"] as String? {
            userId = UUID(uuidString: userIdString)
        }
        title = row["title"]
        description = row["description"]
        category = row["category"]
        deadline = row["deadline"]
        progress = row["progress"]
        isCompleted = row["isCompleted"]
        
        // Convert JSON data back to array
        if let data = row["progressDiary"] as Data? {
            progressDiary = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        } else {
            progressDiary = []
        }
    }
}
