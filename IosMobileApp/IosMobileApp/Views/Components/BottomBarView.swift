import SwiftUI

struct BottomBar: View {
    var addButtonAction: () -> Void
    var homeAction: () -> Void = {}
    var goalsAction: () -> Void = {}
    var profileAction: () -> Void = {}
    var settingsAction: () -> Void = {}
    var helpAction: () -> Void = {}
    var logoutAction: () -> Void = {}

    var body: some View {
        ZStack {
            HStack {
                Button(action: homeAction) {
                    VStack {
                        Image(systemName: "house.fill")
                        Text("Home")

                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)

                Button(action: goalsAction) {
                    VStack {
                        Image(systemName: "target")
                        Text("Goals")
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)

               
                Button(action: profileAction) {
                    VStack {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)

                Menu {
                    Button("Settings", action: settingsAction)
                    Button("Help", action: helpAction)
                    Button("Logout", action: logoutAction)
                } label: {
                    VStack {
                        Image(systemName: "ellipsis.circle")
                        Text("More")
                    }
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .frame(height: 70)
            .background(Color(.systemBackground).ignoresSafeArea())
            .shadow(radius: 3)


        
            .offset(y: -28)
        }
    }
}

#Preview {
    BottomBar(addButtonAction: {
        print("Add tapped")
    })
}
