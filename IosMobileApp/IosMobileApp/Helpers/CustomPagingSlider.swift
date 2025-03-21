import Foundation
import SwiftUI
import SwiftUICore
 



struct CustomPagingSlider<Title: View, Goal: RandomAccessCollection>: View where Goal: MutableCollection, Goal.Element: Identifiable {
    
    var showsIndictor: ScrollIndicatorVisibility = .hidden
    var showPagingControl: Bool = true
    var pagingControlSpacing: CGFloat = 20
    var spacing: CGFloat = 10
    
    @Binding var data : Goal
    @ViewBuilder var title: (Binding<Goal.Element>) -> Title
    
    var body: some View {
        VStack(spacing: pagingControlSpacing) {
            ScrollView(.horizontal) {
                HStack(spacing: spacing) {
                    ForEach($data) { item in
                        VStack(spacing: 0) {
                            title(item)
                            
                        }
                        .containerRelativeFrame(.horizontal)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(showsIndictor)
            .scrollTargetBehavior(.viewAligned)
        }
    }
}

#Preview {
    ContentView()
}
