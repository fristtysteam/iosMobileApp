import Foundation
import SwiftUI
import SwiftUICore
 

struct CustomPagingSlider<Title: View, GoalCollection: RandomAccessCollection>: View where GoalCollection: MutableCollection, GoalCollection.Element: Identifiable {
    
    var showsIndicator: ScrollIndicatorVisibility = .hidden
    var showPagingControl: Bool = true
    var pagingControlSpacing: CGFloat = 20
    var spacing: CGFloat = 10
    
    @Binding var data: GoalCollection
    @ViewBuilder var title: (Binding<GoalCollection.Element>) -> Title
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: pagingControlSpacing) {
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    ForEach($data) { item in
                        VStack(spacing: 0) {
                            title(item)
                                .frame(width: 350, height: 200)
                        }
                    }
                }
            }
            .scrollIndicators(showsIndicator)
        }
    }
}


#Preview {
    ContentView()
}
