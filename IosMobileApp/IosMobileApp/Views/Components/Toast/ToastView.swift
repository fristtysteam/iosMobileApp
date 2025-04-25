import SwiftUI

struct ToastView: View {
    let message: String
    let type: ToastType
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack {
                Spacer()
                HStack(spacing: 12) {
                    type.icon
                        .foregroundColor(.white)
                    
                    Text(message)
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(type.color)
                        .shadow(radius: 5)
                )
                .padding(.bottom, 100)
                .padding(.horizontal, 16)
            }
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isShowing = false
                    }
                }
            }
        }
    }
}

enum ToastType {
    case success
    case error
    case warning
    case info
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .warning: return .orange
        case .info: return .blue
        }
    }
    
    var icon: Image {
        switch self {
        case .success: return Image(systemName: "checkmark.circle.fill")
        case .error: return Image(systemName: "xmark.circle.fill")
        case .warning: return Image(systemName: "exclamationmark.triangle.fill")
        case .info: return Image(systemName: "info.circle.fill")
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2).ignoresSafeArea()
        ToastView(message: "Goal created successfully!", type: .success, isShowing: .constant(true))
    }
} 