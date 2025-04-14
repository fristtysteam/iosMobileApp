import SwiftUI

struct HomeView: View {
    @Binding var goals: [Goal]
    @State private var quote: Quote? = nil
    @State private var isLoadingQuote = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeaderView(title: "Achievr")
                VStack(alignment: .leading, spacing: 6) {
                    Text("👋 Hello, Achiever!")
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

                    VStack(alignment: .leading) {
                        Text("Stay consistent.")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("Every small step counts.")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 10) {
                    Text("🎯 Recent Goals")
                        .font(.title2.bold())

                    CustomPagingSlider(data: $goals) { goal in
                        GoalCardView(title: goal.wrappedValue.title,
                                     description: goal.wrappedValue.description,
                                     progress: goal.wrappedValue.progress,
                                     category: goal.wrappedValue.category,
                                     deadline: goal.wrappedValue.deadline)
                    }
                }
                .padding(.horizontal)


                HStack(spacing: 16) {
                    ProgressBox(title: "Goals", value: "\(goals.count)")
                    ProgressBox(title: "Completed", value: "\(goals.filter { $0.isCompleted }.count)")
                    ProgressBox(title: "In Progress", value: "\(goals.filter { !$0.isCompleted }.count)")
                }
                .padding(.horizontal)


                VStack(alignment: .leading, spacing: 12) {
                    Text("💬 Quote of the Day")
                        .font(.title2.bold())

                    if isLoadingQuote {
                        ProgressView("Fetching quote...")
                    } else if let quote = quote {
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "quote.bubble.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading) {
                                Text("“\(quote.quote)”")
                                    .font(.body)
                                    .italic()
                                    .foregroundColor(.white)
                                Text("- \(quote.author)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.top, 2)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.blue)
                                    .shadow(radius: 5)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                .task {
                    await fetchQuote()
                }

            }
            .padding(.bottom, 100)
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
        .background(RoundedRectangle(cornerRadius: 15).fill(Color(.systemGray6)))
    }
}



#Preview {
    ContentView()
}
