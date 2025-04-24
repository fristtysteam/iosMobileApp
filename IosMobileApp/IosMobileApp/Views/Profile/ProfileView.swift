import SwiftUI
import GRDB
import Combine

struct ProfileView: View {
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showNotificationPermissionAlert = false
    @State private var showBadgesSheet = false
    
    @State private var userBadges: [Badge] = []
    @State private var allBadges: [Badge] = []
    @State private var isLoadingBadges = false
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
            .sheet(isPresented: $showBadgesSheet) {
                NavigationView {
                    BadgeCollectionView(
                        badgeRepository: BadgeRepository(dbQueue: DatabaseManager.shared.getDatabase()),
                        userId: authController.currentUser?.id ?? UUID()
                    )
                    .navigationTitle("Your Badges")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showBadgesSheet = false
                            }
                        }
                    }
                }
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
            .task {
                await loadBadges()
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
                            .foregroundColor(.blue)
                        Text("Edit Profile")
                            .foregroundColor(.primary)
                    }
                }

                Toggle(isOn: notificationToggleBinding) {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.orange)
                        VStack(alignment: .leading) {
                            Text("Notifications")
                                .foregroundColor(.primary)
                            if !notificationService.isPermissionGranted && notificationService.isEnabled {
                                Text("Permission required")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }

            Section(header: Text("Achievements")) {
                Button(action: { showBadgesSheet = true }) {
                    HStack {
                        Image(systemName: "rosette")
                            .foregroundColor(.purple)
                        Text("View Badges")
                            .foregroundColor(.primary)
                        Spacer()
                        if !userBadges.isEmpty {
                            Text("\(userBadges.count) earned")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                if !userBadges.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(userBadges.prefix(5)) { badge in
                                NavigationLink(destination: BadgeDetailView(badge: badge)) {
                                    BadgeView(badge: badge, isEarned: true, size: 50)
                                }
                                .buttonStyle(PlainButtonStyle()) // Optional: removes the blue highlight on tap
                            }
                        }
                        .padding(.vertical, 4)
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
                            .foregroundColor(themeManager.colorScheme == .dark ? .indigo : .orange)
                        Text("Dark Mode")
                            .foregroundColor(.primary)
                    }
                }
            }

            Section {
                Button(action: { showLogoutAlert = true }) {
                    HStack {
                        Image(systemName: "arrow.right.square.fill")
                            .foregroundColor(.red)
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

    private func loadBadges() async {
        guard let userId = authController.currentUser?.id else { return }

        isLoadingBadges = true
        defer { isLoadingBadges = false }

        do {
            let badgeRepository = BadgeRepository(dbQueue: DatabaseManager.shared.getDatabase())
            async let fetchedUserBadges = badgeRepository.getBadgesForUser(userId: userId)
            async let fetchedAllBadges = badgeRepository.getAllBadges()

            let (userBadgesResult, allBadgesResult) = await (try fetchedUserBadges, try fetchedAllBadges)

            await MainActor.run {
                self.userBadges = userBadgesResult
                self.allBadges = allBadgesResult
            }
        } catch {
            print("Error loading badges: \(error)")
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
