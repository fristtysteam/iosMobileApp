import SwiftUI

struct ContentView: View {

    @State private var goals: [Goal] = [
        Goal(id: UUID(), title: "Learn SwiftUI", description: "Build a few UI components using SwiftUI", category: "Programming", deadline: Date().addingTimeInterval(60*60*24*7), progress: 40.0, isCompleted: false, progressDiary: ["Started learning", "Completed 2 tutorials"]),
        Goal(id: UUID(), title: "Finish reading book", description: "Finish reading 'The Swift Programming Language' bookFinish reading 'The Swift Programming Language' bookFinish reading 'The Swift Programming Language' bookFinish reading 'The Swift Programming Language' bookFinish reading 'The Swift Programming Language' book", category: "Reading", deadline: Date().addingTimeInterval(60*60*24*14), progress: 90, isCompleted: false, progressDiary: ["Read the first chapter", "Started chapter 2"]),
        Goal(id: UUID(), title: "Create a Personal Portfolio", description: "Build an online portfolio to showcase projects", category: "Design", deadline: Date().addingTimeInterval(60*60*24*30), progress: 10.0, isCompleted: false, progressDiary: ["Set up a GitHub repository", "Created initial HTML structure"]),
    ]
    
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
                        VStack {
                            Text(goal.wrappedValue.title)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(goal.wrappedValue.description ?? "No description")
                                .frame(maxWidth: 350, alignment: .leading)
                                .font(.subheadline)
                                .lineLimit(1)
                                .foregroundColor(.gray)
                            
                            
                            HStack {
                                CircularProgressView(progress: goal.wrappedValue.progress * 0.01)
                                    .frame(width: 75, height: 75)
                                
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                Spacer()
                                
                                
                                
                                VStack {
                                    VStack {
                                        Text("Category")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        Text(goal.wrappedValue.category ?? "N/A")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    
                                    
                                    VStack {
                                        Text("Deadline")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(goal.wrappedValue.deadline?.formatted(.dateTime.year().month().day()) ?? "N/A")
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .padding()
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
