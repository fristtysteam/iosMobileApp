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
    @State private var showCategorySheet = false
    @State private var showExitConfirmation = false
    
    // Add properties to track initial state
    @State private var didMakeChanges: Bool = false
    
    private var hasUnsavedChanges: Bool {
        // Only consider it "unsaved" if the user actually made changes
        // and there's content to save
        didMakeChanges && (!title.isEmpty || !description.isEmpty || category != "" || progress > 0)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Goal Details").font(.headline).foregroundColor(.blue)) {
                TextField("Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .onChange(of: title) { _ in didMakeChanges = true }

                TextField("Description", text: $description)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 8)
                    .onChange(of: description) { _ in didMakeChanges = true }

                Button(action: {
                    showCategorySheet = true
                }) {
                    HStack {
                        Text(category.isEmpty ? "Select Category" : category)
                            .foregroundColor(category.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Goal Settings").font(.headline).foregroundColor(.blue)) {
                DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                    .padding(.vertical, 8)
                    .onChange(of: deadline) { _ in didMakeChanges = true }
                
                VStack(alignment: .leading) {
                    Text("Progress: \(Int(progress * 100))%")
                    Slider(value: $progress, in: 0...1, step: 0.01)
                        .onChange(of: progress) { _ in didMakeChanges = true }
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
        .confirmExitOnBack(
            if: hasUnsavedChanges,
            showConfirmationDialog: $showExitConfirmation
        )
        .background(Color.white)
        .overlay(
            ToastView(
                message: "Goal created successfully!",
                type: .success,
                isShowing: $showToast
            )
        )
        .sheet(isPresented: $showCategorySheet) {
            CategorySelectionView(selectedCategory: $category)
                .presentationDetents([.large])
                .onDisappear {
                    if !category.isEmpty {
                        didMakeChanges = true
                    }
                }
        }
        .alert("Unsaved Changes", isPresented: $showExitConfirmation) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard Changes", role: .destructive) {
                dismiss()
            }
            if !title.isEmpty {
                Button("Save & Exit") {
                    Task { await saveGoal() }
                }
            }
        } message: {
            Text("You have unsaved changes. Would you like to save them before leaving?")
        }
        .accentColor(.blue)
    }
    
    private func saveGoal() async {
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
        let dbQueue = try! DatabaseQueue()
        let userRepository = UserRepository(dbQueue: dbQueue)
        let goalRepository = GoalRepository(dbQueue: dbQueue)
        let authController = AuthController(userRepository: userRepository, goalRepository: goalRepository)
        AddGoalView(onGoalAdded: { _ in })
            .environmentObject(authController)
    }
}
