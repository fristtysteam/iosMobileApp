import SwiftUI
import GRDB

struct ProfileView: View {
    @State private var notificationsEnabled = false
    @State private var dataSharingEnabled = false
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Profile Header
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text(authController.currentUser?.username ?? "")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(authController.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Settings Section
                List {
                    Section(header: Text("Account")) {
                        Button(action: { showEditProfile = true }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Edit Profile")
                            }
                        }
                        
                        Toggle(isOn: $notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Notifications")
                            }
                        }
                        
                        Toggle(isOn: $dataSharingEnabled) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                Text("Data Sharing")
                            }
                        }
                    }
                    
                    Section(header: Text("Appearance")) {
                        Button(action: { themeManager.toggleTheme() }) {
                            HStack {
                                Image(systemName: themeManager.colorScheme == .dark ? "moon.fill" : "sun.max.fill")
                                Text("Dark Mode")
                                Spacer()
                                Image(systemName: themeManager.colorScheme == .dark ? "checkmark.circle.fill" : "circle")
                            }
                        }
                    }
                    
                    Section {
                        Button(action: { showLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "arrow.right.square.fill")
                                Text("Logout")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditProfile) {
                EditProfileView(
                    currentUsername: authController.currentUser?.username ?? "",
                    currentEmail: authController.currentUser?.email ?? ""
                )
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authController.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let dbQueue = try! DatabaseQueue()
        let userRepository = UserRepository(dbQueue: dbQueue)
        let goalRepository = GoalRepository(dbQueue: dbQueue)
        let authController = AuthController(userRepository: userRepository, goalRepository: goalRepository)
        let themeManager = ThemeManager()
        
        return ProfileView()
            .environmentObject(authController)
            .environmentObject(themeManager)
    }
}

