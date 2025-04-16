import SwiftUI

struct GoalDetailsView: View {
    let goalID: UUID
    @EnvironmentObject var goalController: GoalController
    @Environment(\.dismiss) var dismiss
    @State private var goal: Goal?
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    @State private var editedProgress: Double
    @State private var showAddProgressEntry = false
    @State private var newProgressEntry = ""
    @State private var isLoading = true
    
    init(goalID: UUID) {
        self.goalID = goalID
        _editedProgress = State(initialValue: 0.0)
    }
    
    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let goal = goal {
                goalContent(goal)
            } else {
                errorView
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadGoal()
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading goal details...")
                .foregroundColor(.secondary)
        }
    }
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text("Unable to load goal")
                .font(.headline)
            Text("Please try again later")
                .foregroundColor(.secondary)
            Button("Retry") {
                loadGoal()
            }
            .buttonStyle(.bordered)
        }
    }
    
    private func goalContent(_ goal: Goal) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection(goal)
                progressSection(goal)
                detailsSection(goal)
                progressDiarySection(goal)
                actionButtons(goal)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                        Label("Delete Goal", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .overlay(
            ToastView(
                message: toastMessage,
                type: toastType,
                isShowing: $showToast
            )
        )
        .alert("Delete Goal", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteGoal()
            }
        } message: {
            Text("Are you sure you want to delete this goal? This action cannot be undone.")
        }
        .sheet(isPresented: $showAddProgressEntry) {
            addProgressEntrySheet
        }
    }
    
    private func headerSection(_ goal: Goal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(goal.title)
                .font(.title)
                .fontWeight(.bold)
            
            if let description = goal.description {
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            if let category = goal.category {
                Label(category, systemImage: "tag")
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func progressSection(_ goal: Goal) -> some View {
        VStack(spacing: 16) {
            // Progress Circle
            ZStack {
                Circle()
                    .stroke(lineWidth: 20)
                    .opacity(0.1)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(editedProgress))
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
                    )
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: editedProgress)
                
                VStack {
                    Text("\(Int(editedProgress * 100))%")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 150, height: 150)
            
            // Progress Slider
            VStack(spacing: 8) {
                Slider(value: $editedProgress, in: 0...1, step: 0.01)
                    .tint(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Button("Update Progress") {
                    updateProgress()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .disabled(editedProgress == goal.progress)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private func detailsSection(_ goal: Goal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Status")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(goal.isCompleted ? "Completed" : "In Progress")
                        .font(.body)
                        .foregroundColor(goal.isCompleted ? .green : .blue)
                }
                
                Spacer()
                
                if let deadline = goal.deadline {
                    VStack(alignment: .trailing) {
                        Text("Deadline")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(deadline.formatted(date: .abbreviated, time: .omitted))
                            .font(.body)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private func progressDiarySection(_ goal: Goal) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Progress Diary")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { showAddProgressEntry = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            
            if goal.progressDiary.isEmpty {
                Text("No entries yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(goal.progressDiary.indices, id: \.self) { index in
                    HStack {
                        Text("•")
                            .foregroundColor(.blue)
                        Text(goal.progressDiary[index])
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
    }
    
    private func actionButtons(_ goal: Goal) -> some View {
        HStack {
            Button(action: {
                toggleCompletion(goal)
            }) {
                Label(
                    goal.isCompleted ? "Mark as Incomplete" : "Mark as Complete",
                    systemImage: goal.isCompleted ? "xmark.circle" : "checkmark.circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(goal.isCompleted ? .red : .green)
        }
    }
    
    private var addProgressEntrySheet: some View {
        NavigationView {
            Form {
                Section(header: Text("New Progress Entry")) {
                    TextField("What progress did you make?", text: $newProgressEntry)
                }
            }
            .navigationTitle("Add Progress Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showAddProgressEntry = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addProgressEntry()
                    }
                    .disabled(newProgressEntry.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func loadGoal() {
        isLoading = true
        Task {
            if let loadedGoal = await goalController.getGoalByID(goalID) {
                goal = loadedGoal
                editedProgress = loadedGoal.progress
            }
            isLoading = false
        }
    }
    
    private func updateProgress() {
        guard var updatedGoal = goal else { return }
        updatedGoal.progress = editedProgress
        
        Task {
            if await goalController.updateGoal(updatedGoal) {
                showToast(message: "Progress updated successfully", type: .success)
                loadGoal()
            }
        }
    }
    
    private func toggleCompletion(_ goal: Goal) {
        var updatedGoal = goal
        updatedGoal.isCompleted.toggle()
        
        Task {
            if await goalController.updateGoal(updatedGoal) {
                showToast(
                    message: updatedGoal.isCompleted ? "Goal marked as complete!" : "Goal marked as incomplete",
                    type: .success
                )
                loadGoal()
            }
        }
    }
    
    private func deleteGoal() {
        guard let goalToDelete = goal else { return }
        
        Task {
            if await goalController.deleteGoal(goalToDelete) {
                dismiss()
            }
        }
    }
    
    private func addProgressEntry() {
        guard var updatedGoal = goal else { return }
        updatedGoal.progressDiary.append(newProgressEntry)
        
        Task {
            if await goalController.updateGoal(updatedGoal) {
                showToast(message: "Progress entry added", type: .success)
                newProgressEntry = ""
                showAddProgressEntry = false
                loadGoal()
            }
        }
    }
    
    private func showToast(message: String, type: ToastType) {
        toastMessage = message
        toastType = type
        showToast = true
    }
}
