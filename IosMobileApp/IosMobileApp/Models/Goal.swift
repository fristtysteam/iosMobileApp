import Foundation

class Goal: Identifiable, Codable {
    var id: UUID
    var title: String
    var description: String?
    var category: String?
    var deadline: Date?
    var progress: Double
    var isCompleted: Bool
    var progressDiary: [String]
    
    init(id: UUID = UUID(), title: String, description: String? = nil, category: String? = nil, deadline: Date? = nil, progress: Double = 0.0, isCompleted: Bool = false, progressDiary: [String] = []) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.deadline = deadline
        self.progress = progress
        self.isCompleted = isCompleted
        self.progressDiary = progressDiary
    }
}
