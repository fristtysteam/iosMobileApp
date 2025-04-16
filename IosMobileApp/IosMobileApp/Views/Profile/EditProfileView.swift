import SwiftUI
import GRDB

struct EditProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authController: AuthController
    
    @State private var newUsername: String = ""
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var currentPassword: String = ""
    
    @State private var isLoading: Bool = false
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var toastType: ToastType = .success
    
    init(currentUsername: String, currentEmail: String) {
        _newUsername = State(initialValue: currentUsername)
        _newEmail = State(initialValue: currentEmail)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                Text("Edit Profile")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top)
                
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
                    
                    // Current Password Field
                    SecureTextField(
                        text: $currentPassword,
                        placeholder: "Current Password",
                        icon: "lock.fill"
                    )
                    
                    // New Password Fields (only shown if user wants to change password)
                    if !currentPassword.isEmpty {
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
    }
    
    private func updateProfile() {
        // Input validation
        guard !newUsername.isEmpty else {
            showError("Username cannot be empty")
            return
        }
        
        guard !newEmail.isEmpty else {
            showError("Email cannot be empty")
            return
        }
        
        guard isValidEmail(newEmail) else {
            showError("Please enter a valid email address")
            return
        }
        
        guard !currentPassword.isEmpty else {
            showError("Current password is required")
            return
        }
        
        if !currentPassword.isEmpty && !newPassword.isEmpty {
            guard newPassword == confirmPassword else {
                showError("New passwords don't match")
                return
            }
            
            guard newPassword.count >= 6 else {
                showError("New password must be at least 6 characters")
                return
            }
        }
        
        isLoading = true
        
        Task {
            do {
                try await authController.updateProfile(
                    newUsername: newUsername,
                    newEmail: newEmail,
                    currentPassword: currentPassword,
                    newPassword: !newPassword.isEmpty ? newPassword : nil
                )
                
                toastMessage = "Profile updated successfully"
                toastType = .success
                showToast = true
                
                // Dismiss the view after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                toastMessage = authController.errorMessage
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
        EditProfileView(currentUsername: "test_user", currentEmail: "test@example.com")
            .environmentObject(AuthController(userRepository: userRepository))
    }
} 