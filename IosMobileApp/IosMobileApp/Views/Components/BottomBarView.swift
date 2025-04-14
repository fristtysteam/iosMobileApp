import SwiftUI

struct BottomBar: View {
    @Binding var currentTab: Int

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            BottomBarItem(icon: "house.fill", label: "Home", tabIndex: 0, currentTab: currentTab) {
                currentTab = 0
            }

            BottomBarItem(icon: "target", label: "Goals", tabIndex: 1, currentTab: currentTab) {
                currentTab = 1
            }

            BottomBarItem(icon: "person.crop.circle", label: "Profile", tabIndex: 2, currentTab: currentTab) {
                currentTab = 2
            }

            Menu {
                Button("Settings", action: {})
                Button("Help", action: {})
                Button("Logout", action: {})
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: "ellipsis.circle")
                    Text("More")
                }
                .frame(maxHeight: .infinity)
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary) 
            }
        }
        .frame(height: 70)
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
        .shadow(radius: 3)
    }
}




struct BottomBarItem: View {
    var icon: String
    var label: String
    var tabIndex: Int
    var currentTab: Int
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.caption)
            }
            .frame(maxHeight: .infinity)
            .frame(maxWidth: .infinity)
            .foregroundColor(tabIndex == currentTab ? .blue : .primary)
        }
    }
}




#Preview {
    ContentView()
}
