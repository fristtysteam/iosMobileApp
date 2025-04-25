import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var goalController: GoalController
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Summary Cards
                HStack(spacing: 16) {
                    StatCard(
                        title: "Total Goals",
                        value: "\(goalController.goals.count)",
                        icon: "target",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Completed",
                        value: "\(goalController.goals.filter(\.isCompleted).count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                }
                .padding(.horizontal)
                
            
                CompletionRateView(goals: goalController.goals)
                    .padding(.horizontal)
                
            
                RecentActivityView(goals: goalController.goals)
                    .padding(.horizontal)
                
                
                CategoryDistributionView(goals: goalController.goals)
                    .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Analytics")
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await goalController.loadGoals()
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct CompletionRateView: View {
    let goals: [Goal]
    
    private var completionRate: Double {
        guard !goals.isEmpty else { return 0 }
        return Double(goals.filter(\.isCompleted).count) / Double(goals.count) * 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Completion Rate")
                .font(.headline)
            
            HStack(alignment: .bottom, spacing: 8) {
                Text("\(Int(completionRate))%")
                    .font(.system(size: 36, weight: .bold))
                Text("completed")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(completionRate >= 70 ? Color.green : completionRate >= 40 ? Color.orange : Color.red)
                        .frame(width: geometry.size.width * CGFloat(completionRate / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct RecentActivityView: View {
    let goals: [Goal]
    
    private var recentlyCompletedGoals: [Goal] {
        goals.filter(\.isCompleted)
            .sorted { ($0.deadline ?? Date()) > ($1.deadline ?? Date()) }
            .prefix(5)
            .map { $0 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Completions")
                .font(.headline)
            
            if recentlyCompletedGoals.isEmpty {
                Text("No completed goals yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(recentlyCompletedGoals) { goal in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(goal.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            if let deadline = goal.deadline {
                                Text(deadline, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 8)
                    
                    if goal.id != recentlyCompletedGoals.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct CategoryDistributionView: View {
    let goals: [Goal]
    
    private var categoryData: [(category: String, count: Int)] {
        let grouped = Dictionary(grouping: goals, by: { $0.category ?? "Uncategorized" })
        return grouped.map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Distribution")
                .font(.headline)
            
            if goals.isEmpty {
                Text("No goals yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Chart {
                    ForEach(categoryData, id: \.category) { item in
                        SectorMark(
                            angle: .value("Count", item.count),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", item.category))
                    }
                }
                .frame(height: 200)
                
                // Legend
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(categoryData, id: \.category) { item in
                        HStack {
                            Text(item.category)
                                .font(.subheadline)
                            Spacer()
                            Text("\(item.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
