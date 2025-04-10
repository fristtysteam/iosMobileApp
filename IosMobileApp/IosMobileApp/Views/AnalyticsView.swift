import SwiftUI
import Charts

struct AnalyticsView: View {
    // Sample Goal data
    @State private var goals: [Goal] = [
        Goal(title: "Goal A", deadline: dateFrom("2025-03-01"), isCompleted: true),
        Goal(title: "Goal B", deadline: dateFrom("2025-03-01"), isCompleted: true),
        Goal(title: "Goal C", deadline: dateFrom("2025-03-02"), isCompleted: true),
        Goal(title: "Goal D", deadline: dateFrom("2025-03-03"), isCompleted: true),
        Goal(title: "Goal E", deadline: dateFrom("2025-03-03"), isCompleted: true),
        Goal(title: "Goal F", deadline: dateFrom("2025-03-03"), isCompleted: true)
    ]
    
    @State private var streakCount: Int = 3
    @State private var insights: String = "Very good work and productivity!"
    
    var completedGoalsByDate: [CompletedGoalData] {
        let grouped = Dictionary(grouping: goals.filter { $0.isCompleted && $0.deadline != nil }) {
            dateFormatter.string(from: $0.deadline!)
        }
        return grouped.map { CompletedGoalData(date: $0.key, count: $0.value.count) }
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ProgressChartView(completedGoals: completedGoalsByDate)
                    StreakTrackerView(streakCount: streakCount)
                    HistoricalDataView(completedGoals: completedGoalsByDate)
                    InsightsView(insights: insights)
                }
                .padding()
                .navigationTitle("Progress")
            }
        }
    }
}

struct ProgressChartView: View {
    var completedGoals: [CompletedGoalData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress Chart")
                .font(.headline)
            
            Chart {
                ForEach(completedGoals) { goal in
                    BarMark(
                        x: .value("Date", goal.date),
                        y: .value("Goals", goal.count)
                    )
                    .foregroundStyle(Color.blue)
                }
            }
            .frame(height: 250)
            .padding(10)
        }
    }
}


struct HistoricalDataView: View {
    var completedGoals: [CompletedGoalData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Historical Data")
                .font(.headline)
            
            ForEach(completedGoals) { goal in
                HStack {
                    Text(goal.date)
                        .font(.subheadline)
                    Spacer()
                    Text("\(goal.count) goals")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(5)
            }
        }
        .padding(.horizontal)
    }
}

struct StreakTrackerView: View {
    var streakCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Streak")
                .font(.headline)
            
            Text("You have completed goals for \(streakCount) consecutive days!")
                .font(.subheadline)
                .foregroundColor(.green)
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(5)
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
            
            Text(insights)
                .font(.subheadline)
                .padding(10)
                .background(Color.white)
                .cornerRadius(5)
                .shadow(radius: 2)
        }
        .padding(.horizontal)
    }
}


#Preview {
    AnalyticsView()
}



struct CompletedGoalData: Identifiable {
    var id: String { date }
    var date: String
    var count: Int
}


private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

private func dateFrom(_ string: String) -> Date? {
    dateFormatter.date(from: string)
}
