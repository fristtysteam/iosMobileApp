import SwiftUI
import GRDB

enum GoalCategory: String, CaseIterable {
    case personal = "Personal Growth"
    case career = "Career & Work"
    case health = "Health & Wellness"
    case learning = "Learning & Skills"
    case financial = "Financial"
    case relationships = "Relationships"
    case fitness = "Fitness"
    case mindfulness = "Mindfulness"
    case productivity = "Productivity"
    case creativity = "Creativity"
    
    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .career: return "briefcase.fill"
        case .health: return "heart.fill"
        case .learning: return "book.fill"
        case .financial: return "dollarsign.circle.fill"
        case .relationships: return "person.2.fill"
        case .fitness: return "figure.run"
        case .mindfulness: return "brain.head.profile"
        case .productivity: return "chart.bar.fill"
        case .creativity: return "paintbrush.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .personal: return .blue
        case .career: return .purple
        case .health: return .green
        case .learning: return .orange
        case .financial: return .mint
        case .relationships: return .pink
        case .fitness: return .red
        case .mindfulness: return .indigo
        case .productivity: return .teal
        case .creativity: return .yellow
        }
    }
}

struct AddGoalView: View {
    let onGoalAdded: (UUID) -> Void
    @EnvironmentObject var goalController: GoalController
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: GoalCategory = .personal
    @State private var deadline: Date = Date()
    @State private var progress: Double = 0.0
    @State private var isCompleted: Bool = false
    @State private var showToast = false
    @State private var showingDatePicker = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
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
                }
                
                Section(header: Text("Category")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(GoalCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                    }
                    .listRowInsets(EdgeInsets())
                }
                
                Section(header: Text("Goal Settings").font(.headline).foregroundColor(.blue)) {
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                        .padding(.vertical, 8)
                    
                    VStack(alignment: .leading) {
                        Text("Progress: \(Int(progress * 100))%")
                        Slider(value: $progress, in: 0...1, step: 0.01)
                    }
                    .padding(.vertical, 8)
                }
                
                if let errorMessage = goalController.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: {
                        Task { await saveGoal() }
                    }) {
                        if goalController.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Goal")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .disabled(title.isEmpty || goalController.isLoading)
                }
            }
            .navigationTitle("Add New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white)
            .overlay(
                ToastView(
                    message: "Goal created successfully!",
                    type: .success,
                    isShowing: $showToast
                )
            )
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    DatePicker("Select Deadline",
                              selection: $deadline,
                              in: Date()...,
                              displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .navigationTitle("Select Deadline")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") {
                                    showingDatePicker = false
                                }
                            }
                        }
                }
                .presentationDetents([.medium])
            }
            .alert("Error", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .accentColor(.blue)
    }
    
    private func saveGoal() async {
        let newGoal = Goal(
            title: title,
            description: description.isEmpty ? nil : description,
            category: selectedCategory.rawValue,
            deadline: deadline,
            progress: progress,
            isCompleted: isCompleted
        )
        
        if let createdGoalID = await goalController.createGoal(
            title: title,
            description: description.isEmpty ? nil : description,
            category: selectedCategory.rawValue,
            deadline: deadline,
            progress: progress,
            isCompleted: isCompleted
        ) {
            withAnimation {
                showToast = true
            }
            
            // Wait for the toast to show before dismissing
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                onGoalAdded(createdGoalID)
                presentationMode.wrappedValue.dismiss()
            }
        } else {
            alertMessage = "Failed to create goal"
            showingAlert = true
        }
    }
}

struct CategoryButton: View {
    let category: GoalCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 24))
                Text(category.rawValue)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 80)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color.opacity(0.2) : Color(.systemGray6))
            )
            .foregroundColor(isSelected ? category.color : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Preview
struct AddGoalView_Previews: PreviewProvider {
    static var previews: some View {
        let dbQueue = DatabaseManager.shared.getDatabase()
        let repository = GoalRepository(dbQueue: dbQueue)
        let controller = GoalController(goalRepository: repository)
        
        return VStack {
            HeaderView(title: "Achievr")
            AddGoalView(onGoalAdded: { _ in })
                .environmentObject(controller)
        }
    }
}
