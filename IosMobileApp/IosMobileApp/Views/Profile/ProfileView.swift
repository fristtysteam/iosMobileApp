import SwiftUI
import GRDB
import Combine

struct ProfileView: View {
    @State private var notificationsEnabled = false
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    
    // Observer for forcing view refresh when data changes
    @State private var viewRefreshCounter = 0
    
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var userController: UserController
    @EnvironmentObject var themeManager: ThemeManager
    
    // Current user data derived from authController for binding in views
    private var username: String { 
        authController.currentUser?.username ?? ""
    }
    
    private var email: String {
        authController.currentUser?.email ?? ""
    }
    
    // Get profile image directly from current user data each time
    private var profileImage: UIImage? {
        guard let imageData = authController.currentUser?.profilePictureData else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Profile Header with ID for refresh
                HStack {
                    // Use the viewRefreshCounter for forcing refresh
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
                
                // Settings Section
                List {
                    Section(header: Text("Account")) {
                        Button(action: { showEditProfile = true }) {
                            HStack {
                                Image(systemName: "person.fill")
                                Text("Edit Profile")
                            }
                            .foregroundColor(.primary)
                        }
                        
                        Toggle(isOn: $notificationsEnabled) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Notifications")
                            }
                        }
                    }
                    
                    Section(header: Text("Appearance")) {
                        Toggle(isOn: Binding(
                            get: { themeManager.colorScheme == .dark },
                            set: { _ in themeManager.toggleTheme() }
                        )) {
                            HStack {
                                Image(systemName: themeManager.colorScheme == .dark ? "moon.fill" : "sun.max.fill")
                                Text("Dark Mode")
                            }
                            .foregroundColor(.primary)
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
            .sheet(isPresented: $showEditProfile, onDismiss: {
                // Completely refresh the view after editing
                refreshProfileData()
            }) {
                EditProfileView(
                    currentUsername: username,
                    currentEmail: email,
                    currentProfileImage: profileImage
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
            .onAppear {
                // Refresh when the view appears
                refreshProfileData()
            }
        }
    }
    
    // Strong refresh method that forces a complete data reload
    private func refreshProfileData() {
        Task {
            // First load new data from database
            await authController.refreshCurrentUser()
            
            // Then force UI update on the main thread
            await MainActor.run {
                print("Refreshing profile view with new data!")
                // Increment refresh counter to force SwiftUI to rebuild the views
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


