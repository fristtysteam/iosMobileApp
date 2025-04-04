import SwiftUI

struct GoalDetailsView: View {
    var goal: UserGoal
    @State private var isEditing: Bool = false
    @State private var title: String
    @State private var description: String
    @State private var category: String
    @State private var deadline: Date
    @State private var progress: Double
    @State private var isCompleted: Bool
    
    init(goal: UserGoal) {
        _title = State(initialValue: goal.title)
        _description = State(initialValue: goal.description)
        _category = State(initialValue: goal.category)
        _deadline = State(initialValue: goal.deadline)
        _progress = State(initialValue: goal.progress)
        _isCompleted = State(initialValue: goal.isCompleted)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if isEditing {
                Form {
                    Section(header: Text("Goal Details").font(.headline).foregroundColor(.blue)) {
                        TextField("Title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Description", text: $description)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Category", text: $category)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Goal Settings").font(.headline).foregroundColor(.blue)) {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                        
                        Slider(value: $progress, in: 0...100, step: 1) {
                            Text("Progress")
                        }
                        .padding()
                        
                        Toggle("Completed", isOn: $isCompleted)
                            .padding()
                    }
                    
                    Section {
                        Button("Save Changes") {
                            // Save edited goal (you can implement saving logic here)
                            isEditing.toggle()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Title: \(goal.title)")
                        .font(.headline)
                    
                    Text("Description: \(goal.description)")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    Text("Category: \(goal.category)")
                        .font(.body)
                        .foregroundColor(.blue)
                    
                    Text("Deadline: \(goal.deadline, formatter: DateFormatter.shortDate)")
                        .font(.body)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("Progress: \(Int(goal.progress))%")
                            .font(.body)
                        ProgressBar(value: goal.progress)
                            .frame(width: 100, height: 10)
                            .cornerRadius(5)
                    }
                    
                    Toggle(isOn: $isCompleted) {
                        Text(isCompleted ? "Completed" : "Not Completed")
                            .font(.body)
                            .foregroundColor(isCompleted ? .green : .red)
                    }
                    .disabled(true)
                    .padding()
                    
                    HStack {
                        Button("Edit") {
                            isEditing.toggle()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        
                        Button("Delete") {
                            // Implement delete logic (e.g., removing from list or database)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .foregroundColor(Color.gray.opacity(0.3))
                .frame(height: 10)
            
            Capsule()
                .foregroundColor(Color.blue)
                .frame(width: CGFloat(value), height: 10)
        }
    }
}

struct GoalDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalDetailsView(goal: UserGoal(title: "Learn Swift", description: "Complete all the Swift courses", category: "Education", deadline: Date(), progress: 60, isCompleted: false))
    }
}
