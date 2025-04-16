import SwiftUI
import GRDB
import Photos

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var userController: UserController
    
    @State private var newUsername: String = ""
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var currentPassword: String = ""
    
    // Profile image state variables
    @State private var profileImage: UIImage?
    @State private var showImagePicker: Bool = false
    @State private var hasChangedImage: Bool = false
    @State private var showPermissionAlert: Bool = false
    
    @State private var isLoading: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastType: ToastType = .success
    
    // Store initial values to detect changes
    private let initialUsername: String
    private let initialEmail: String
    
    init(currentUsername: String, currentEmail: String, currentProfileImage: UIImage? = nil) {
        self.initialUsername = currentUsername
        self.initialEmail = currentEmail
        _newUsername = State(initialValue: currentUsername)
        _newEmail = State(initialValue: currentEmail)
        _profileImage = State(initialValue: currentProfileImage)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Edit Profile")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Profile Image Selector
                VStack {
                    CircleImage(image: profileImage, size: 120)
                        .padding(.bottom, 10)
                    
                    Button(action: {
                        checkPhotoLibraryPermission()
                    }) {
                        Text(profileImage == nil ? "Add Profile Picture" : "Change Picture")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
                
                // Form Fields
                VStack(spacing: 15) {
                    // Username Field
                    CustomTextField(
                        text: $newUsername,
                        placeholder: "Username",
                        icon: "person.fill"
                    )
                    
                    // Email Field
                    CustomTextField(
                        text: $newEmail,
                        placeholder: "Email",
                        icon: "envelope.fill"
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    
                    // Password Section
                    VStack(alignment: .leading, spacing: 10) {
                        Divider()
                            .padding(.vertical, 5)
                        
                        Text("Change Password")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.top, 5)
                    
                    // Current Password Field
                    SecureTextField(
                        text: $currentPassword,
                        placeholder: "Current Password",
                        icon: "lock.fill"
                    )
                    
                    // New Password Fields
                    SecureTextField(
                        text: $newPassword,
                        placeholder: "New Password",
                        icon: "lock.fill"
                    )
                    
                    SecureTextField(
                        text: $confirmPassword,
                        placeholder: "Confirm New Password",
                        icon: "lock.fill"
                    )
                }
                .padding(.horizontal)
                
                // Update Button
                Button(action: updateProfile) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Update Profile")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(isLoading)
                
                Spacer()
            }
            .padding(.bottom, 50) // Add extra padding at bottom for keyboard
        }
        .scrollDismissesKeyboard(.interactively)
        .overlay(
            ToastView(
                message: toastMessage,
                type: toastType,
                isShowing: $showToast
            )
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $profileImage, isPresented: $showImagePicker)
                .onDisappear {
                    if let newImage = profileImage {
                        hasChangedImage = true
                    }
                }
        }
        .alert("Photo Library Access", isPresented: $showPermissionAlert) {
            Button("Settings", role: .none) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please allow access to your photo library to select a profile picture.")
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    if status == .authorized || status == .limited {
                        self.showImagePicker = true
                    } else {
                        self.showPermissionAlert = true
                    }
                }
            }
        case .restricted, .denied:
            showPermissionAlert = true
        case .authorized, .limited:
            showImagePicker = true
        @unknown default:
            showPermissionAlert = true
        }
    }
    
    private func updateProfile() {
        isLoading = true
        
        // Convert image to data if it exists and has changed
        var profileImageData: Data? = nil
        if hasChangedImage, let image = profileImage {
            profileImageData = image.jpegData(compressionQuality: 0.7)
        }
        
        Task {
            do {
                // If password fields are empty, use the simple profile update
                if currentPassword.isEmpty {
                    // Input validation for basic profile update
                    guard !newUsername.isEmpty else {
                        showError("Username cannot be empty")
                        isLoading = false
                        return
                    }
                    
                    guard !newEmail.isEmpty else {
                        showError("Email cannot be empty")
                        isLoading = false
                        return
                    }
                    
                    guard isValidEmail(newEmail) else {
                        showError("Please enter a valid email address")
                        isLoading = false
                        return
                    }
                    
                    // Basic profile info update without password
                    try await userController.updateProfileInfo(
                        newUsername: newUsername,
                        newEmail: newEmail,
                        profilePictureData: hasChangedImage ? profileImageData : nil
                    )
                } else {
                    // Password is provided, validate and use the full profile update
                    guard isValidEmail(newEmail) else {
                        showError("Please enter a valid email address")
                        isLoading = false
                        return
                    }
                    
                    if !newPassword.isEmpty {
                        guard newPassword == confirmPassword else {
                            showError("New passwords don't match")
                            isLoading = false
                            return
                        }
                        
                        guard newPassword.count >= 6 else {
                            showError("New password must be at least 6 characters")
                            isLoading = false
                            return
                        }
                    }
                    
                    // Full profile update with password
                    try await userController.updateProfile(
                        newUsername: newUsername,
                        newEmail: newEmail,
                        currentPassword: currentPassword,
                        newPassword: !newPassword.isEmpty ? newPassword : nil,
                        profilePictureData: hasChangedImage ? profileImageData : nil
                    )
                }
                
                toastMessage = "Profile updated successfully"
                toastType = .success
                showToast = true
                
                // Dismiss the view after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                toastMessage = userController.errorMessage ?? "Failed to update profile"
                toastType = .error
                showToast = true
            }
            
            isLoading = false
        }
    }
    
    private func showError(_ message: String) {
        toastMessage = message
        toastType = .error
        showToast = true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// Helper view for text fields
struct CustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Helper view for secure fields
struct SecureTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
                .frame(width: 20)
            SecureField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let dbQueue = try! DatabaseQueue()
        let userRepository = UserRepository(dbQueue: dbQueue)
        let goalRepository = GoalRepository(dbQueue: dbQueue)
        let authController = AuthController(userRepository: userRepository, goalRepository: goalRepository)
        let userController = UserController(userRepository: userRepository, authController: authController)
        
        EditProfileView(currentUsername: "test_user", currentEmail: "test@example.com")
            .environmentObject(authController)
            .environmentObject(userController)
    }
} 