import SwiftUI

struct GoalConnectPage: View {
    @State private var showingAddGoal = false
    @State private var showingGoalDetails = false
    @State private var showingAnalytics = false
    
    private let sampleGoal: Goal = {
        let calendar = Calendar.current
        let deadline = calendar.date(byAdding: .day, value: 30, to: Date())
        return Goal(
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
                            action: { showingGoalDetails = true }
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
                        
                        InspirationCard()
                    }
                    .padding(.top, 8)
                }
                .padding(.bottom, 80)
            }
            // Navigation Destinations
            .navigationDestination(isPresented: $showingAddGoal) {
                AddGoalView()
                    .navigationBarTitle("New Goal", displayMode: .inline)
            }
            .navigationDestination(isPresented: $showingGoalDetails) {
                GoalDetailsView(goal: sampleGoal)
                    .navigationBarTitle("Goal Details", displayMode: .inline)
            }
            .navigationDestination(isPresented: $showingAnalytics) {
                AnalyticsView() 
                    .navigationBarTitle("Progress Insights", displayMode: .inline)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
