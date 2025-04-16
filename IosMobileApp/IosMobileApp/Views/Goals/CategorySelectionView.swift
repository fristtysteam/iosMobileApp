import SwiftUI

struct CategoryOption: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
}

struct CategorySelectionView: View {
    @Binding var selectedCategory: String
    @Environment(\.dismiss) var dismiss
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let categories = [
        CategoryOption(name: "Work", icon: "briefcase.fill", color: .blue),
        CategoryOption(name: "Personal", icon: "person.fill", color: .purple),
        CategoryOption(name: "Health", icon: "heart.fill", color: .red),
        CategoryOption(name: "Education", icon: "book.fill", color: .orange),
        CategoryOption(name: "Finance", icon: "dollarsign.circle.fill", color: .green),
        CategoryOption(name: "Fitness", icon: "figure.run", color: .pink),
        CategoryOption(name: "Travel", icon: "airplane", color: .cyan),
        CategoryOption(name: "Home", icon: "house.fill", color: .brown),
        CategoryOption(name: "Hobby", icon: "paintbrush.fill", color: .indigo),
        CategoryOption(name: "Social", icon: "person.2.fill", color: .teal)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Select a Category")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(categories) { category in
                            CategoryBox(
                                category: category,
                                isSelected: selectedCategory == category.name
                            )
                            .onTapGesture {
                                selectedCategory = category.name
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CategoryBox: View {
    let category: CategoryOption
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Image(systemName: category.icon)
                .font(.system(size: 30))
                .foregroundColor(isSelected ? .white : category.color)
            
            Text(category.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? category.color : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(category.color, lineWidth: isSelected ? 0 : 2)
        )
    }
}

#Preview {
    CategorySelectionView(selectedCategory: .constant("Work"))
} 