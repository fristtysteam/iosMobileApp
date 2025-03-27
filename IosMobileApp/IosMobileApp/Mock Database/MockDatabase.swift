import Foundation

class MockDatabase {
    static let shared = MockDatabase()
    
    private let fileName = "mock_database.json"
    
    private func getFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    func load() -> [User]? {
        let fileURL = getFileURL()
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601 
            let usersData = try decoder.decode([String: [User]].self, from: data)
            return usersData["users"]
        } catch {
            print("Error loading data: \(error)")
            return nil
        }
    }
    
    func save(users: [User]) {
        let fileURL = getFileURL()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(["users": users])
            try data.write(to: fileURL)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    

    func addGoalToUser(userId: UUID, goal: Goal) {
        if var users = load() {
            // Find the user
            if let userIndex = users.firstIndex(where: { $0.id == userId }) {
                var user = users[userIndex]
                
                user.goals.append(goal)
                users[userIndex] = user
                
                save(users: users)
                print("Goal added successfully.")
            } else {
                print("User not found.")
            }
        }
    }
    

    func editUserGoal(userId: UUID, goalId: UUID, newTitle: String, newProgress: Double) {
        if var users = load() {
            if let userIndex = users.firstIndex(where: { $0.id == userId }) {
                var user = users[userIndex]
                
                if let goalIndex = user.goals.firstIndex(where: { $0.id == goalId }) {
                    var goal = user.goals[goalIndex]
                    
                    goal.title = newTitle
                    goal.progress = newProgress
                    
                    user.goals[goalIndex] = goal
                    
            
                    users[userIndex] = user
                    
                
                    save(users: users)
                    print("Goal updated successfully.")
                } else {
                    print("Goal not found.")
                }
            } else {
                print("User not found.")
            }
        }
    }
    
    // Delete a goal from a user's goals
    func deleteUserGoal(userId: UUID, goalId: UUID) {
        if var users = load() {
            // Find the user
            if let userIndex = users.firstIndex(where: { $0.id == userId }) {
                var user = users[userIndex]
                
                // Find and delete the goal for this user
                if let goalIndex = user.goals.firstIndex(where: { $0.id == goalId }) {
                    user.goals.remove(at: goalIndex)
                    
                    // Update the user in the list
                    users[userIndex] = user
                    
                    // Save the updated data
                    save(users: users)
                    print("Goal deleted successfully.")
                } else {
                    print("Goal not found.")
                }
            } else {
                print("User not found.")
            }
        }
    }
}
