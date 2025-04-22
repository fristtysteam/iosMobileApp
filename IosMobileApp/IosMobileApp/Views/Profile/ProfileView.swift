import SwiftUI
import GRDB
import Combine

struct ProfileView: View {
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showNotificationPermissionAlert = false
    
    @State private var viewRefreshCounter = 0
    
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var notificationService = NotificationService.shared
    
    private var username: String { 
        authController.currentUser?.username ?? ""
    }
    
    private var email: String {
        authController.currentUser?.email ?? ""
    }
    
    private var profileImage: UIImage? {
        guard let imageData = authController.currentUser?.profilePictureData else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    private var notificationToggleBinding: Binding<Bool> {
        Binding(
            get: { notificationService.isEnabled },
            set: { newValue in
                if newValue && !notificationService.isPermissionGranted {
                    showNotificationPermissionAlert = true
                }
                notificationService.toggleNotifications(newValue)
            }
        )
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                profileHeader
                settingsList
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditProfile, onDismiss: {
                refreshProfileData()
            }) {
                EditProfileView(
                    currentUsername: username,
                    currentEmail: email,
                    currentProfileImage: profileImage
                )
            }
            .alert("Enable Notifications", isPresented: $showNotificationPermissionAlert) {
                Button("Cancel") {
                    notificationService.toggleNotifications(false)
                }
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Please enable notifications in Settings to receive goal updates.")
            }
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    authController.logout()
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
            .onAppear {
                refreshProfileData()
            }
        }
    }
    
    private var profileHeader: some View {
        HStack {
            CircleImage(image: profileImage, size: 80)
                .padding()
                .id("profile-img-\(viewRefreshCounter)")
            
            VStack(alignment: .leading) {
                Text(username)
                    .font(.title2)
                    .fontWeight(.bold)
                    .id("username-\(viewRefreshCounter)")
                
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .id("email-\(viewRefreshCounter)")
            }
            .padding(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
    
    private var settingsList: some View {
        List {
            Section(header: Text("Account")) {
                Button(action: { showEditProfile = true }) {
                    HStack {
                        Image(systemName: "person.fill")
                        Text("Edit Profile")
                    }
                }
                
                Toggle(isOn: notificationToggleBinding) {
                    HStack {
                        Image(systemName: "bell.fill")
                        VStack(alignment: .leading) {
                            Text("Notifications")
                            if !notificationService.isPermissionGranted && notificationService.isEnabled {
                                Text("Permission required")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
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
    
    private func refreshProfileData() {
        Task {
            await authController.refreshCurrentUser()
            await MainActor.run {
                print("Refreshing profile view with new data!")
                viewRefreshCounter += 1
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
        let userController = UserController(userRepository: userRepository, authController: authController)
        let themeManager = ThemeManager()
        
        return ProfileView()
            .environmentObject(authController)
            .environmentObject(userController)
            .environmentObject(themeManager)
    }
}
