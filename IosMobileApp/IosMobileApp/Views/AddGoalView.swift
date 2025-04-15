import SwiftUI
import GRDB

struct AddGoalView: View {
    @EnvironmentObject var goalRepository: GoalRepository
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var deadline: Date = Date()
    @State private var progress: Double = 0.0
    @State private var isCompleted: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details").font(.headline).foregroundColor(.blue)) {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)

                    TextField("Description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)

                    TextField("Category", text: $category)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Goal Settings").font(.headline).foregroundColor(.blue)) {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                        .padding(.vertical, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Progress: \(Int(progress * 100))%")
                        Slider(value: $progress, in: 0...1, step: 0.01)
                    }
                    .padding(.vertical, 8)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        Task { await saveGoal() }
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save Goal")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .disabled(title.isEmpty || isLoading)
                }
            }
            .navigationTitle("Add New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
        }
        .accentColor(.blue)
    }
    
    private func saveGoal() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let newGoal = Goal(
                title: title,
                description: description.isEmpty ? nil : description,
                category: category.isEmpty ? nil : category,
                deadline: deadline,
                progress: progress,
                isCompleted: isCompleted
            )
            
            try await goalRepository.saveGoal(newGoal)
            dismiss()
        } catch {
            errorMessage = "Failed to save goal: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Preview
struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        let dbQueue = DatabaseManager.shared.getDatabase()
        let repository = GoalRepository(dbQueue: dbQueue)
        
        return VStack {
            HeaderView(title: "Achievr")
            AddGoalView()
                .environmentObject(repository)
        }
    }
}
