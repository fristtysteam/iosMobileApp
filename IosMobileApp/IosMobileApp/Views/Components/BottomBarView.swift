import SwiftUI

struct BottomBar: View {
    var addButtonAction: () -> Void
    
    var body: some View {
        HStack {
            Button(action: { /* Home Action */ }) {
                Image(systemName: "house.fill")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.primary)
            }
            .padding()

            Spacer()

            Button(action: addButtonAction) {
                Image(systemName: "plus")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(100)
                    .shadow(radius: 3)
            }

            Spacer()

            Menu {
                Button("Settings", action: {})
                Button("Logout", action: {})
            } label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .frame(width: 28, height: 6)
                    .foregroundColor(.primary)
                    .padding()
            }
        }
        .padding(.vertical)
        .frame(height: 70)
        .background(Color(.white))
        //.cornerRadius(15)
        .shadow(radius: 5)
        //.padding, 16)
    }

}

#Preview {
    BottomBar(addButtonAction: {})
}
