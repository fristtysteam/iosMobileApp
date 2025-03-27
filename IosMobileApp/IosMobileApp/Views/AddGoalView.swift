import SwiftUI

struct AddGoalView: View {
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var deadline: Date = Date()
    @State private var progress: Double = 0.0
    @State private var isCompleted: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details").font(.headline).foregroundColor(.blue)) {
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)

                    TextField("Description", text: $description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)

                    TextField("Category", text: $category)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("Goal Settings").font(.headline).foregroundColor(.blue)) {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                        .padding(.vertical, 8)
                }
                
                
                Section {
                    Button(action: {
                        //function to add will do later
                    }) {
                        Text("Save Goal")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                }
            }
            .navigationTitle("Add New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
        }
        .accentColor(.blue)
    }
}

#Preview {
    AddGoalView()
}
