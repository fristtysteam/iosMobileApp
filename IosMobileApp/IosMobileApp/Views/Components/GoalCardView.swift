import SwiftUICore

struct GoalCardView: View {
    let title: String
    let description: String?
    let progress: Double
    let category: String?
    let deadline: Date?
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .lineLimit(1)
            
            if let description = description, !description.isEmpty {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            HStack(spacing: 20) {
                CircularProgressView(progress: progress)
                    .frame(width: 75, height: 75)
                
                VStack(alignment: .leading, spacing: 12) {
                    if let category = category {
                        HStack(spacing: 6) {
                            Image(systemName: "tag.fill")
                                .font(.caption)
                            Text(category)
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    if let deadline = deadline {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(deadline.formatted(.dateTime.year().month().day()))
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
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


