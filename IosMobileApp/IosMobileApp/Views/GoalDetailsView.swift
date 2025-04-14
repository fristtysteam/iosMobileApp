import SwiftUI

struct GoalDetailsView: View {
    @EnvironmentObject var goalRepository: GoalRepository
    @Environment(\.dismiss) var dismiss
    var goal: Goal
    
    @State private var isEditing = false
    @State private var editedGoal: Goal
    @State private var isLoading = false
    @State private var showDeleteAlert = false
    @State private var error: String?
    
    init(goal: Goal) {
        self.goal = goal
        self._editedGoal = State(initialValue: goal)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if isEditing {
                    editingView
                } else {
                    displayView
                }
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        .alert("Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error ?? "")
        }
        .alert("Delete Goal", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task { await deleteGoal() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this goal?")
        }
    }
    
    @ViewBuilder
    private var editingView: some View {
        Form {
            Section(header: Text("Goal Info").font(.headline)) {
                TextField("Title", text: $editedGoal.title)
                
                TextField("Description", text: Binding(
                    get: { editedGoal.description ?? "" },
                    set: { editedGoal.description = $0.isEmpty ? nil : $0 }
                ))
                
                TextField("Category", text: Binding(
                    get: { editedGoal.category ?? "" },
                    set: { editedGoal.category = $0.isEmpty ? nil : $0 }
                ))
            }
            
            Section(header: Text("Progress & Status").font(.headline)) {
                DatePicker("Deadline", selection: Binding(
                    get: { editedGoal.deadline ?? Date() },
                    set: { editedGoal.deadline = $0 }
                ), displayedComponents: [.date])
                
                VStack(alignment: .leading) {
                    Text("Progress: \(Int(editedGoal.progress * 100))%")
                    Slider(value: $editedGoal.progress, in: 0...1, step: 0.01)
                }
                
                Toggle("Completed", isOn: $editedGoal.isCompleted)
            }
            
            Section {
                Button(action: {
                    Task { await saveChanges() }
                }) {
                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Save Changes")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
                
                Button("Cancel") {
                    isEditing = false
                    editedGoal = goal
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    @ViewBuilder
    private var displayView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                Text(goal.title)
                    .font(.title)
                    .fontWeight(.bold)
                
                if let desc = goal.description, !desc.isEmpty {
                    Text(desc)
                        .font(.body)
                        .foregroundColor(.gray)
                }
                
                if let cat = goal.category, !cat.isEmpty {
                    Label(cat, systemImage: "tag")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
                if let deadline = goal.deadline {
                    Label("Due: \(deadline.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Progress")
                    .font(.headline)
                
                ProgressBar(value: goal.progress * 100)
                    .frame(height: 12)
                
                Text("\(Int(goal.progress * 100))% Complete")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: goal.isCompleted ? "checkmark.seal.fill" : "xmark.seal")
                    .foregroundColor(goal.isCompleted ? .green : .red)
                Text(goal.isCompleted ? "Completed" : "Not Completed")
                    .font(.subheadline)
                    .foregroundColor(goal.isCompleted ? .green : .red)
            }
            .padding(.top, 8)
            
            HStack(spacing: 16) {
                Button("Edit") {
                    editedGoal = goal
                    isEditing = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("Delete") {
                    showDeleteAlert = true
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding()
    }
    
    private func saveChanges() async {
        isLoading = true
        do {
            try await goalRepository.saveGoal(editedGoal)
            isEditing = false
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
    
    private func deleteGoal() async {
        isLoading = true
        do {
            try await goalRepository.deleteGoal(goal)
            dismiss()
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 10)
                    .foregroundColor(Color.gray.opacity(0.3))
                
                Capsule()
                    .frame(width: geometry.size.width * CGFloat(value / 100), height: 10)
                    .foregroundColor(.blue)
            }
        }
        .frame(height: 10)
    }
}

#Preview {
    let dbQueue = DatabaseManager.shared.getDatabase()
    let repository = GoalRepository(dbQueue: dbQueue)
    
    NavigationStack {
        GoalDetailsView(goal: Goal(
            title: "Learn Swift",
            description: "Complete all the Swift courses",
            category: "Education",
            deadline: Date(),
            progress: 0.6,
            isCompleted: false
        ))
        .environmentObject(repository)
    }
}
