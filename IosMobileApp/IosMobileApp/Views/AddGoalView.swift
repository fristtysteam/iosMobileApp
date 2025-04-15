import SwiftUI
import GRDB

struct AddGoalView: View {
    let onGoalAdded: (UUID) -> Void
    @EnvironmentObject var goalController: GoalController
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var deadline: Date = Date()
    @State private var progress: Double = 0.0
    @State private var isCompleted: Bool = false
    @State private var showToast = false
    
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
                
                if let errorMessage = goalController.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        Task { await saveGoal() }
                    }) {
                        if goalController.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Goal")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .disabled(title.isEmpty || goalController.isLoading)
                }
            }
            .navigationTitle("Add New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
            .overlay(
                ToastView(
                    message: "Goal created successfully!",
                    type: .success,
                    isShowing: $showToast
                )
            )
        }
        .accentColor(.blue)
    }
    
    private func saveGoal() async {
        let newGoal = Goal(
            title: title,
            description: description.isEmpty ? nil : description,
            category: category.isEmpty ? nil : category,
            deadline: deadline,
            progress: progress,
            isCompleted: isCompleted
        )
        
        if let createdGoalID = await goalController.createGoal(
            title: title,
            description: description.isEmpty ? nil : description,
            category: category.isEmpty ? nil : category,
            deadline: deadline,
            progress: progress,
            isCompleted: isCompleted
        ) {
            withAnimation {
                showToast = true
            }
            
            // Wait for the toast to show before dismissing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                onGoalAdded(createdGoalID)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// MARK: - Preview
struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        let dbQueue = DatabaseManager.shared.getDatabase()
        let repository = GoalRepository(dbQueue: dbQueue)
        let controller = GoalController(goalRepository: repository)
        
        return VStack {
            HeaderView(title: "Achievr")
            AddGoalView(onGoalAdded: { _ in })
                .environmentObject(controller)
        }
    }
}
