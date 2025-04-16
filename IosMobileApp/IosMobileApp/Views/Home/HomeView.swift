import SwiftUI

struct HomeView: View {
    @Binding var goals: [Goal]
    @State private var quote: Quote? = nil
    @State private var isLoadingQuote = false
    @EnvironmentObject var goalController: GoalController
    @EnvironmentObject var authController: AuthController
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView(title: "Achievr", useGradient: true)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome back, \(authController.currentUser?.username ?? "User")! 👋")
                        .font(.largeTitle.bold())
                    Text(Date(), style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

               
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 140)
                        .shadow(radius: 5)

                    if isLoadingQuote {
                        ProgressView("Fetching quote...")
                            .foregroundColor(.white)
                    } else if let quote = quote {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\"\(quote.quote)\"")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            Text("- \(quote.author)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    } else {
                        VStack(alignment: .leading) {
                            Text("Loading your daily inspiration...")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                }
                .padding(.horizontal)
                .task {
                    if quote == nil {
                        await fetchQuote()
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("🎯 Recent Goals")
                        .font(.title2.bold())

                    CustomPagingSlider(data: $goals) { goal in
                        NavigationLink(destination: GoalDetailsView(goalID: goal.wrappedValue.id)) {
                            GoalCardView(title: goal.wrappedValue.title,
                                     description: goal.wrappedValue.description,
                                     progress: goal.wrappedValue.progress,
                                     category: goal.wrappedValue.category,
                                     deadline: goal.wrappedValue.deadline)
                        }
                    }
                }
                .padding(.horizontal)

                HStack(spacing: 16) {
                    ProgressBox(title: "Goals", value: "\(goals.count)")
                    ProgressBox(title: "Completed", value: "\(goals.filter { $0.isCompleted }.count)")
                    ProgressBox(title: "In Progress", value: "\(goals.filter { !$0.isCompleted }.count)")
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 100)
        }
        .refreshable {
            Task {
                await goalController.loadGoals()
            }
        }
    }

    private func fetchQuote() async {
        isLoadingQuote = true
        do {
            quote = try await performQuotesApiCall()
        } catch {
            print("Failed to load quote: \(error)")
        }
        isLoadingQuote = false
    }
}

struct ProgressBox: View {
    var title: String
    var value: String
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack {
            Text(value)
                .font(.title.bold())
                .foregroundColor(.blue)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
        )
    }
}

#Preview {
    ContentView()
}
