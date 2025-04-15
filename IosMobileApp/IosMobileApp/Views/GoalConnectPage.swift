import SwiftUI

struct GoalConnectPage: View {
    @State private var showingAddGoal = false
    @State private var showingGoalDetails = false
    @State private var showingAnalytics = false
    @State private var selectedGoalID: UUID?

    private let sampleGoal: Goal = {
        let calendar = Calendar.current
        let deadline = calendar.date(byAdding: .day, value: 30, to: Date())
        return Goal(
            id: UUID(), // Ensure this ID exists in your database when testing
            title: "Learn SwiftUI",
            description: "Master SwiftUI fundamentals to build beautiful iOS apps",
            category: "Education",
            deadline: deadline,
            progress: 0.25,
            isCompleted: false,
            progressDiary: ["Started learning", "Completed basic views"]
        )
    }()

    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HeaderView(title: "Achievr")

            ScrollView {
                VStack(spacing: 28) {
                    // Page Heading
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Goal Connect")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(
                                colors: [.blue, .indigo],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .shadow(color: .blue.opacity(0.1), radius: 5, x: 0, y: 2)

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
                            action: {
                                selectedGoalID = sampleGoal.id // Pass your actual goal ID here
                                showingGoalDetails = true
                            }
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
            AddGoalView()
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

                // Chevron indicator
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
