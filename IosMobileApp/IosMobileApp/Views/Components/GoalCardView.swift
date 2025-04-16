import SwiftUICore

struct GoalCardView: View {
    let title: String
    let description: String?
    let progress: Double
    let category: String?
    let deadline: Date?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(description ?? "No description")
                .frame(maxWidth: 350, alignment: .leading)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                CircularProgressView(progress: progress * 0.01)
                    .frame(width: 75, height: 75)
                
                Spacer()
                
                VStack {
                    VStack {
                        Text("Category")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                        
                        Text(category ?? "N/A")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack {
                        Text("Deadline")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                        Text(deadline?.formatted(.dateTime.year().month().day()) ?? "N/A")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                .shadow(color: colorScheme == .dark ? .clear : .gray.opacity(0.2),
                       radius: 8, x: 0, y: 2)
        )
    }
}


