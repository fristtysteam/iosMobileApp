import SwiftUI
import Charts

struct AnalyticsView: View {
    // Hardcoded data
    @State private var completedGoals: [UserGoal] = [
        UserGoal(date: "2025-03-01", count: 5),
        UserGoal(date: "2025-03-02", count: 3),
        UserGoal(date: "2025-03-03", count: 7)
    ]
    
    @State private var streakCount: Int = 3
    @State private var insights: String = "very good work and productivity!"
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressChartView(completedGoals: completedGoals)
                    
                    StreakTrackerView(streakCount: streakCount)
                    
                    HistoricalDataView(completedGoals: completedGoals)
                    
                    InsightsView(insights: insights)
                }
                .padding()
                .navigationTitle("Progress")
                .background(Color.accentColor.opacity(0.05))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Image(systemName: "chart.bar.fill")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}
    
    // MARK: - Progress Chart View
    struct ProgressChartView: View {
        var completedGoals: [UserGoal]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Progress Chart")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.top)
                
                ZStack {
                    Color.white
                        .cornerRadius(2)
                        .shadow(radius: 1)
                    
                    Chart {
                        ForEach(completedGoals, id: \.date) { goal in
                            BarMark(
                                x: .value("Date", goal.date),
                                y: .value("Goals", goal.count)
                            )
                            .foregroundStyle(Color.accentColor)
                        }
                    }
                    .frame(height: 250)
                    .padding(10)
                }
            }
        }
    }
    
    // MARK: - Streak Tracker View
    struct StreakTrackerView: View {
        var streakCount: Int
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Current Streak")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Text("You have completed goals for \(streakCount) consecutive days!")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(3)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(3)
                .shadow(radius: 1)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Historical Data View
    struct HistoricalDataView: View {
        var completedGoals: [UserGoal]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Historical Data")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ForEach(completedGoals, id: \.date) { goal in
                    HStack {
                        Text(goal.date)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(goal.count) goals")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 5)
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(2)
                    .shadow(radius: 1)
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Insights View
    struct InsightsView: View {
        var insights: String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Insights on Productivity")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(insights)
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.top, 5)
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(2)
                    .shadow(radius: 1)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - UserGoal Model
    struct UserGoal {
        var date: String
        var count: Int
    }
    
    struct AnalyticsView_Previews: PreviewProvider {
        static var previews: some View {
            AnalyticsView()
        }
    }

#Preview {
    ContentView()

}
