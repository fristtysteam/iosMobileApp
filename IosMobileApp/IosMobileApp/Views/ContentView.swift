import SwiftUI

struct ContentView: View {
    @State private var goals: [Goal] = [
        Goal(id: UUID(), title: "Learn SwiftUI", description: "Build a few UI components using SwiftUI", category: "Programming", deadline: Date().addingTimeInterval(60*60*24*7), progress: 40.0, isCompleted: false, progressDiary: ["Started learning", "Completed 2 tutorials"]),
        Goal(id: UUID(), title: "Finish reading book", description: "Finish reading 'The Swift Programming Language' book", category: "Reading", deadline: Date().addingTimeInterval(60*60*24*14), progress: 20.0, isCompleted: false, progressDiary: ["Read the first chapter", "Started chapter 2"]),
        Goal(id: UUID(), title: "Create a Personal Portfolio", description: "Build an online portfolio to showcase projects", category: "Design", deadline: Date().addingTimeInterval(60*60*24*30), progress: 10.0, isCompleted: false, progressDiary: ["Set up a GitHub repository", "Created initial HTML structure"]),
    ]
    
    var body: some View {
        VStack {
            HeaderView(title: "Achievr")
        
            
            CustomPagingSlider(data: $goals) { goal in
                VStack {
                    Text(goal.wrappedValue.title)
                        .font(.headline)
                    
                    Text(goal.wrappedValue.description ?? "No description")  // Use a default value in case description is nil
                        .font(.subheadline)
                        .lineLimit(2)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            // No Spacer() needed here, content is already under the header
            
        }
        .padding()  // Optional padding for the whole view
    }
}

#Preview {
    ContentView()
}
