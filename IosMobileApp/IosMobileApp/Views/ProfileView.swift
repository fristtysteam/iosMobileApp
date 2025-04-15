import SwiftUI

struct ProfileSettingsView: View {
    @State private var notificationsEnabled = false
    @State private var dataSharingEnabled = false
    @EnvironmentObject var userController: UserController

    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Image("profile_pic")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text(userController.username)
                            .font(.headline)
                        Text(userController.email)
                            .font(.subheadline)
                    }
                    .padding(.leading)
                }

               
                Toggle(isOn: $notificationsEnabled) {
                    Text("Enable Notifications")
                }
                .padding()
                
                Toggle(isOn: $dataSharingEnabled) {
                    Text("Share Data")
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Profile Settings")
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView()
            .environmentObject(UserController())
    }
}

