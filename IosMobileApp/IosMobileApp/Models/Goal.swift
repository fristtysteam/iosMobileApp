import Foundation


class Goal: Identifiable {
    var id: UUID
    var title: String
    var description: String?
    var category: String?
    var deadline: Date?
    var progress: Double
    var isCompleted: Bool
    var progressDiary: [String]
    
    init(id: UUID, title: String, description: String, category: String? = nil, deadline: Date? = nil, progress: Double, isCompleted: Bool, progressDiary: [String]) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.category = category
        self.deadline = deadline
        self.progress = 0.0
        self.isCompleted = false
        self.progressDiary = []
    }
}
