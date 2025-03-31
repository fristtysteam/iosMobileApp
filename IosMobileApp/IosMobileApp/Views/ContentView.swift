import SwiftUI

struct ContentView: View {

    @State private var goals: [Goal] = [
        Goal(id: UUID(), title: "Learn SwiftUI", description: "Build a few UI components using SwiftUI", category: "Programming", deadline: Date().addingTimeInterval(60*60*24*7), progress: 40.0, isCompleted: false, progressDiary: ["Started learning", "Completed 2 tutorials"]),
        Goal(id: UUID(), title: "Finish reading book", description: "Finish reading 'The Swift Programming Language' bookFinish reading 'The Swift Programming Language' bookFinish reading 'The Swift Programming Language' bookFinish reading 'The Swift Programming Language' bookFinish reading 'The Swift Programming Language' book", category: "Reading", deadline: Date().addingTimeInterval(60*60*24*14), progress: 90, isCompleted: false, progressDiary: ["Read the first chapter", "Started chapter 2"]),
        Goal(id: UUID(), title: "Create a Personal Portfolio", description: "Build an online portfolio to showcase projects", category: "Design", deadline: Date().addingTimeInterval(60*60*24*30), progress: 10.0, isCompleted: false, progressDiary: ["Set up a GitHub repository", "Created initial HTML structure"]),
    ]
    
    @State var quote:  Quote?
    
    var body: some View {
        ScrollView {
            VStack {
                HeaderView(title: "Achievr")
                
                VStack {
                    Text("Recent Goals")
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    CustomPagingSlider(data: $goals) { goal in
                        GoalCardView(title: goal.wrappedValue.title, description: goal.wrappedValue.description, progress: goal.wrappedValue.progress, category: goal.wrappedValue.category, deadline: goal.wrappedValue.deadline)
                    }
                }
                
                Spacer()
                Spacer()
                Spacer()
                
                
                VStack {
                    Text("Quote Of The Day")
                        .font(.title)
                        .italic()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                    VStack {
                        if let quote {
                            Text(quote.quote)
                                .font(.caption)
                        }
                        //COULD HAVE STOCK PHOTO OF MAN WITH SPEECH BUBBLE BESIDE
                    }
                    .task {
                        do {
                            let res = try await performQuotesApiCall()
                            quote = res
                        } catch {
                            print("Error: \(error)")
                            // Handle the error as needed
                        }
                    }
                
                }
                
            }
            .padding()
            
        }
    }
}

#Preview {
    ContentView()
}
