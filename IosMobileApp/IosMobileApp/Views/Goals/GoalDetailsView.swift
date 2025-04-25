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
    @State private var showExitConfirmation = false
    @State private var didMakeChanges = false
    
    // Edit mode states
    @State private var editedTitle = ""
    @State private var editedDescription = ""
    @State private var editedCategory: String?
    @State private var editedDeadline: Date?
    @State private var showCategoryPicker = false
    @State private var showDatePicker = false
    
    private var hasUnsavedChanges: Bool {
        if !isEditing { return false }
        
        // Only consider changes if values are actually different from the original
        guard let originalGoal = goal else { return false }
        
        let titleChanged = editedTitle != originalGoal.title
        let descriptionChanged = editedDescription != (originalGoal.description ?? "")
        let categoryChanged = editedCategory != originalGoal.category
        let deadlineChanged = editedDeadline != originalGoal.deadline
        let progressChanged = editedProgress != originalGoal.progress
        
        return titleChanged || descriptionChanged || categoryChanged || 
               deadlineChanged || progressChanged || didMakeChanges
    }
    
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
        .confirmExitOnBack(
            if: hasUnsavedChanges,
            showConfirmationDialog: $showExitConfirmation
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    if isEditing {
                        Button("Save") {
                            saveChanges()
                        }
                    }
                    Menu {
                        if !isEditing {
                            Button(action: { 
                                isEditing.toggle()
                            }) {
                                Label("Edit Goal", systemImage: "pencil")
                            }
                        }
                        Button(role: .destructive, action: { showDeleteConfirmation = true }) {
                            Label("Delete Goal", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("Unsaved Changes", isPresented: $showExitConfirmation) {
            Button("Keep Editing", role: .cancel) { }
            Button("Discard Changes", role: .destructive) {
                didMakeChanges = false
                isEditing = false
                dismiss()
            }
            Button("Save & Exit") {
                saveChanges()
                dismiss()
            }
        } message: {
            Text("You have unsaved changes. Would you like to save them before leaving?")
        }
        .onAppear {
            loadGoal()
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
    }
    
    private func headerSection(_ goal: Goal) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditing {
                TextField("Goal Title", text: $editedTitle)
                    .font(.title)
                    .fontWeight(.bold)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: editedTitle) { _ in didMakeChanges = true }
                
                TextField("Description", text: $editedDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: editedDescription) { _ in didMakeChanges = true }
                
                Button(action: { showCategoryPicker = true }) {
                    HStack {
                        Image(systemName: "tag")
                        Text(editedCategory ?? "Add Category")
                            .foregroundColor(editedCategory == nil ? .secondary : .blue)
                    }
                }
                .sheet(isPresented: $showCategoryPicker) {
                    CategorySelectionView(selectedCategory: Binding(
                        get: { editedCategory ?? "" },
                        set: { 
                            editedCategory = $0
                            didMakeChanges = true
                        }
                    ))
                }
                
                Button(action: { showDatePicker = true }) {
                    HStack {
                        Image(systemName: "calendar")
                        Text(editedDeadline?.formatted(date: .abbreviated, time: .omitted) ?? "Add Deadline")
                            .foregroundColor(editedDeadline == nil ? .secondary : .blue)
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    DatePicker("Deadline",
                             selection: Binding(
                                get: { editedDeadline ?? Date() },
                                set: { 
                                    editedDeadline = $0
                                    didMakeChanges = true
                                }
                             ),
                             displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .presentationDetents([.medium])
                }
            } else {
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
                
                if let deadline = goal.deadline {
                    Label(deadline.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(radius: 5)
        )
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
                    .onChange(of: editedProgress) { _ in 
                        if isEditing {
                            didMakeChanges = true
                        }
                    }
                
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
                // Initialize edit mode states
                editedTitle = loadedGoal.title
                editedDescription = loadedGoal.description ?? ""
                editedCategory = loadedGoal.category
                editedDeadline = loadedGoal.deadline
            }
            isLoading = false
        }
    }
    
    private func updateProgress() {
        guard var updatedGoal = goal else { return }
        updatedGoal.progress = editedProgress
        
        // Auto-mark as complete if progress is 100%
        if editedProgress == 1.0 {
            updatedGoal.isCompleted = true
        }
        else {
            updatedGoal.isCompleted = false
        }
        
        Task {
            if await goalController.updateGoal(updatedGoal) {
                showToast(message: "Progress updated successfully", type: .success)
                didMakeChanges = false
                loadGoal()
            }
        }
    }
    
    private func toggleCompletion(_ goal: Goal) {
        var updatedGoal = goal
        updatedGoal.isCompleted.toggle()
        
        // Set progress to 100% when completing, keep existing progress when uncompleting
        if updatedGoal.isCompleted {
            updatedGoal.progress = 1.0
            editedProgress = 1.0
        }
        
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
    
    private func saveChanges() {
        guard var updatedGoal = goal else { return }
        updatedGoal.title = editedTitle
        updatedGoal.description = editedDescription
        updatedGoal.category = editedCategory
        updatedGoal.deadline = editedDeadline
        
        Task {
            if await goalController.updateGoal(updatedGoal) {
                showToast(message: "Goal updated successfully", type: .success)
                didMakeChanges = false
                isEditing = false
                loadGoal()
            } else {
                showToast(message: "Failed to update goal", type: .error)
            }
        }
    }
    
    private func showToast(message: String, type: ToastType) {
        toastMessage = message
        toastType = type
        showToast = true
    }
}
