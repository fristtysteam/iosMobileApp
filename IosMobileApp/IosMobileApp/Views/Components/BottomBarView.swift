import SwiftUI

struct BottomBarView: View {
    @Binding var currentTab: Int
    @EnvironmentObject var authController: AuthController
    @State private var showLogoutAlert = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            BottomBarItem(
                icon: "house.fill",
                label: "Home",
                tabIndex: 0,
                currentTab: currentTab,
                action: { currentTab = 0 }
            )
            
            BottomBarItem(
                icon: "target",
                label: "Goals",
                tabIndex: 1,
                currentTab: currentTab,
                action: { currentTab = 1 }
            )
            
            BottomBarItem(
                icon: "person.crop.circle",
                label: "Profile",
                tabIndex: 2,
                currentTab: currentTab,
                action: { currentTab = 2 }
            )
        }
        .frame(height: 70)
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
    }
}

struct BottomBarItem: View {
    let icon: String
    let label: String
    let tabIndex: Int
    let currentTab: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.caption)
            }
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .foregroundColor(tabIndex == currentTab ? .gray : .primary)
        }
    }
}

struct BottomBarView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var currentTab = 0
        
        var body: some View {
            VStack {
                Spacer()
                BottomBarView(currentTab: $currentTab)
            }
        }
    }
}
