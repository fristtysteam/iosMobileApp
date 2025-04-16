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

                    // Recent Goals Section
                    if !goalController.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Recent Goals")
                                .font(.headline)
                                .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(goalController.goals.prefix(3)) { goal in
                                        Button(action: {
                                            selectedGoalID = goal.id
                                            showingGoalDetails = true
                                        }) {
                                            RecentGoalCard(goal: goal)
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                    }

                    // Motivational section
                    VStack(spacing: 16) {
                        Text("Daily Inspiration")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 8)
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

struct RecentGoalCard: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(goal.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            if let category = goal.category {
                Label(category, systemImage: "tag")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            ProgressView(value: goal.progress)
                .tint(goal.isCompleted ? .green : .blue)
        }
        .padding()
        .frame(width: 280)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
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
