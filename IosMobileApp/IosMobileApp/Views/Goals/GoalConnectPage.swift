import SwiftUI

struct GoalConnectPage: View {
    @EnvironmentObject var goalController: GoalController
    @State private var showingAddGoal = false
    @State private var showingGoalDetails = false
    @State private var showingAnalytics = false
    @State private var selectedGoalID: UUID?
    @State private var showingGoalsList = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HeaderView(title: "Goal Connect", useGradient: true)

            ScrollView {
                VStack(spacing: 28) {
                    // Page Heading
                    VStack(alignment: .leading, spacing: 8) {

                        Text("Design your personal growth journey")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.leading, 2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)

                    // Action Cards
                    VStack(spacing: 20) {
                        ActionCard(
                            icon: "plus.circle.fill",
                            title: "Create New Goal",
                            subtitle: "Set a new objective to achieve",
                            color: .blue,
                            action: { showingAddGoal = true }
                        )

                        ActionCard(
                            icon: "list.bullet.rectangle.portrait.fill",
                            title: "My Goals",
                            subtitle: "Track your progress and details",
                            color: .green,
                            action: { showingGoalsList = true }
                        )

                        ActionCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "Progress Analytics",
                            subtitle: "View your achievement trends",
                            color: .orange,
                            action: { showingAnalytics = true }
                        )
                    }
                    .padding(.horizontal, 20)

                    // Timeline Section
                    if !goalController.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Goal Timeline")
                                .font(.headline)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 0) {
                                ForEach(goalController.goals.prefix(5)) { goal in
                                    TimelineItemView(goal: goal) {
                                        selectedGoalID = goal.id
                                        showingGoalDetails = true
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }

                }
                .padding(.bottom, 80)
            }
        }
        .navigationDestination(isPresented: $showingAddGoal) {
            AddGoalView(onGoalAdded: { newGoalID in
                Task {
                    await goalController.loadGoals()
                    selectedGoalID = newGoalID
                    showingGoalDetails = true
                }
            })
        }
        .navigationDestination(isPresented: $showingGoalsList) {
            GoalListView()
        }
        .navigationDestination(isPresented: $showingGoalDetails) {
            if let goalID = selectedGoalID {
                GoalDetailsView(goalID: goalID)
            }
        }
        .navigationDestination(isPresented: $showingAnalytics) {
            AnalyticsView()
        }
    }
}

struct TimelineItemView: View {
    let goal: Goal
    let action: () -> Void
    @Environment(\.colorScheme) var colorScheme
    
    private var statusColor: Color {
        if goal.isCompleted {
            return .green
        } else if goal.progress > 0 {
            return .orange
        } else {
            return .gray
        }
    }
    
    private var formattedDate: String {
        if let deadline = goal.deadline {
            return deadline.formatted(.dateTime.month().day())
        }
        return "No deadline"
    }
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 16) {
                // Timeline dot and line
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(statusColor.opacity(0.3))
                        .frame(width: 2)
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    Rectangle()
                        .fill(statusColor.opacity(0.3))
                        .frame(width: 2)
                }
                .frame(height: 80)
                
                // Content
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .center, spacing: 8) {
                        Text(goal.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        if goal.isCompleted {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Text(formattedDate)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        if let category = goal.category {
                            Text(category)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(Int(goal.progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(statusColor)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: colorScheme == .dark ? .clear : .black.opacity(0.03),
                               radius: 3, x: 0, y: 1)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [color.opacity(0.3), color.opacity(0.1)],
                                center: .center,
                                angle: .degrees(45)
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.7))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
