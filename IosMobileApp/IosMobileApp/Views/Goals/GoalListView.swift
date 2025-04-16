import SwiftUI

struct GoalListView: View {
    @EnvironmentObject var goalController: GoalController
    @State private var searchText = ""
    @State private var selectedFilter: GoalFilter = .all
    @State private var showingSortOptions = false
    @State private var sortOrder: GoalSortOrder = .dateCreated
    @State private var showingClearConfirmation = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    
    private var filteredGoals: [Goal] {
        var goals = goalController.goals
        
        // Apply search filter
        if !searchText.isEmpty {
            goals = goals.filter { goal in
                goal.title.localizedCaseInsensitiveContains(searchText) ||
                goal.description?.localizedCaseInsensitiveContains(searchText) ?? false ||
                goal.category?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .completed:
            goals = goals.filter { $0.isCompleted }
        case .inProgress:
            goals = goals.filter { !$0.isCompleted }
        }
        
        // Apply sorting
        switch sortOrder {
        case .dateCreated:
            goals.sort { $0.deadline ?? Date.distantFuture < $1.deadline ?? Date.distantFuture }
        case .title:
            goals.sort { $0.title < $1.title }
        case .progress:
            goals.sort { $0.progress > $1.progress }
        }
        
        return goals
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Filter Bar
            VStack(spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search goals...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(GoalFilter.allCases, id: \.self) { filter in
                            FilterPill(
                                title: filter.title,
                                isSelected: filter == selectedFilter,
                                action: { selectedFilter = filter }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            if filteredGoals.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredGoals) { goal in
                        NavigationLink(destination: GoalDetailsView(goalID: goal.id)) {
                            GoalRowView(goal: goal)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteGoal(goal)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("My Goals")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { showingSortOptions = true }) {
                        Label("Sort Goals", systemImage: "arrow.up.arrow.down")
                    }
                    
                    Button(role: .destructive, action: { showingClearConfirmation = true }) {
                        Label("Clear All Goals", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .actionSheet(isPresented: $showingSortOptions) {
            ActionSheet(
                title: Text("Sort Goals"),
                buttons: [
                    .default(Text("By Date")) { sortOrder = .dateCreated },
                    .default(Text("By Title")) { sortOrder = .title },
                    .default(Text("By Progress")) { sortOrder = .progress },
                    .cancel()
                ]
            )
        }
        .alert("Clear All Goals", isPresented: $showingClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                clearAllGoals()
            }
        } message: {
            Text("Are you sure you want to delete all goals? This action cannot be undone.")
        }
        .overlay(
            ToastView(
                message: toastMessage,
                type: toastType,
                isShowing: $showToast
            )
        )
        .onAppear {
            Task {
                await goalController.loadGoals()
            }
        }
    }
    
    private func deleteGoal(_ goal: Goal) {
        Task {
            if await goalController.deleteGoal(goal) {
                showToast(message: "Goal deleted successfully", type: .success)
            }
        }
    }
    
    private func clearAllGoals() {
        Task {
            if await goalController.clearAllGoals() {
                showToast(message: "All goals cleared successfully", type: .success)
            }
        }
    }
    
    private func showToast(message: String, type: ToastType) {
        toastMessage = message
        toastType = type
        showToast = true
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "target")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(searchText.isEmpty ? "No goals yet" : "No matching goals")
                .font(.headline)
            
            Text(searchText.isEmpty ? "Create your first goal to get started!" : "Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

struct GoalRowView: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(goal.title)
                    .font(.headline)
                Spacer()
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if let description = goal.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack(spacing: 16) {
                if let category = goal.category {
                    Label(category, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                if let deadline = goal.deadline {
                    Label(deadline.formatted(date: .abbreviated, time: .omitted),
                          systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: goal.progress)
                .tint(goal.isCompleted ? .green : .blue)
        }
        .padding(.vertical, 8)
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

enum GoalFilter: CaseIterable {
    case all, completed, inProgress
    
    var title: String {
        switch self {
        case .all: return "All"
        case .completed: return "Completed"
        case .inProgress: return "In Progress"
        }
    }
}

enum GoalSortOrder {
    case dateCreated, title, progress
}