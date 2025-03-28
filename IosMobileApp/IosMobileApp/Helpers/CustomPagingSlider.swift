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
    
    var body: some View {
        VStack(spacing: pagingControlSpacing) {
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    ForEach($data) { item in
                        VStack(spacing: 0) {
                            title(item)
                                .frame(width: 350, height: 200)
                                .background(Color.white)
                                .cornerRadius(8)
                                .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)
                                .padding(15)
                            
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
