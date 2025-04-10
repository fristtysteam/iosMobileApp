import SwiftUI

struct GoalDetailsView: View {
    var goal: Goal

    @State private var isEditing: Bool = false
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var category: String = ""
    @State private var deadline: Date = Date()
    @State private var progress: Double = 0
    @State private var isCompleted: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                if isEditing {
                    Form {
                        Section(header: Text("Goal Info").font(.headline)) {
                            TextField("Title", text: $title)

                            TextField("Description", text: $description)

                            TextField("Category", text: $category)
                        }

                        Section(header: Text("Progress & Status").font(.headline)) {
                            DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])

                            VStack(alignment: .leading) {
                                Text("Progress: \(Int(progress))%")
                                Slider(value: $progress, in: 0...100, step: 1)
                            }

                            Toggle("Completed", isOn: $isCompleted)
                        }

                        Section {
                            Button(action: {
                                // Save changes
                                isEditing.toggle()
                            }) {
                                Text("Save Changes")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        Group {
                            Text(goal.title)
                                .font(.title)
                                .fontWeight(.bold)

                            if let desc = goal.description, !desc.isEmpty {
                                Text(desc)
                                    .font(.body)
                                    .foregroundColor(.gray)
                            }

                            if let cat = goal.category, !cat.isEmpty {
                                Label(cat, systemImage: "tag")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }

                            if let deadline = goal.deadline {
                                Label("Due: \(deadline.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar")
                                    .foregroundColor(.secondary)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Progress")
                                .font(.headline)

                            ProgressBar(value: goal.progress)
                                .frame(height: 12)

                            Text("\(Int(goal.progress))% Complete")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        HStack {
                            Image(systemName: isCompleted ? "checkmark.seal.fill" : "xmark.seal")
                                .foregroundColor(isCompleted ? .green : .red)
                            Text(isCompleted ? "Completed" : "Not Completed")
                                .font(.subheadline)
                                .foregroundColor(isCompleted ? .green : .red)
                        }
                        .padding(.top, 8)

                        HStack(spacing: 16) {
                            Button("Edit") {
                                title = goal.title
                                description = goal.description ?? ""
                                category = goal.category ?? ""
                                deadline = goal.deadline ?? Date()
                                progress = goal.progress
                                isCompleted = goal.isCompleted
                                isEditing.toggle()
                            }
                            .buttonStyle(.borderedProminent)

                            Button("Delete") {
                                // Implement delete logic
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                        .padding(.top)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding()
                }
            }
            .onAppear {
                isCompleted = goal.isCompleted
            }
        }
        .navigationTitle("Goal Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground))
        
    }
    
}

struct ProgressBar: View {
    var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .frame(height: 10)
                    .foregroundColor(Color.gray.opacity(0.3))

                Capsule()
                    .frame(width: geometry.size.width * CGFloat(value / 100), height: 10)
                    .foregroundColor(.blue)
            }
        }
        .frame(height: 10)
    }
}

struct GoalDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GoalDetailsView(goal: Goal(title: "Learn Swift", description: "Complete all the Swift courses", category: "Education", deadline: Date(), progress: 60, isCompleted: false))
        }
    }
}
