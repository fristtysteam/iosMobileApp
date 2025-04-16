import SwiftUI
import Combine



// All UI updates must happen on the main thread. Since AuthController drives the state of UI through @Published properties
// (like isAuthenticated, username, showError), it's
// important those updates happen on the main thread thats why use MainActor
@MainActor
class AuthController: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    @Published var registrationSuccess: Bool = false
    @Published var users: [User] = []
    @Published var isAuthenticated = false {
          didSet {
              print("Auth state changed to: \(isAuthenticated)")
              objectWillChange.send()
          }
      }
    

    @Published var isUsernameValid: Bool = true
    @Published var isPasswordValid: Bool = true
    @Published var isEmailValid: Bool = true
    @Published var isLoading = false
    
    private(set) var currentUser: User?
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
        Task {
            await loadUsers()
        }
    }
    
  
    func loadUserDetails() {
        username = ""
        password = ""
        email = ""
        registrationSuccess = false
        showError = false
    }

    
  
    func loadUsers() async {
        do {
            self.users = try await userRepository.getAllUsers()
            print("Loaded \(users.count) users from database")
        } catch {
            print("Failed to load users: \(error)")
        }
    }
    
 
    func registerUser() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        // Validate first
        if !validateRegistration() {
            return
        }
        
        do {
            let user = try await userRepository.register(
                username: username,
                email: email,
                password: password
            )
            
            // Clear form and set success
            loadUserDetails()
            registrationSuccess = true
            isAuthenticated = true
            currentUser = user
            await loadUsers() // Refresh users list
            
        } catch AuthError.usernameTaken {
            errorMessage = "Username already taken"
            showError = true
        } catch {
            errorMessage = "Registration failed"
            showError = true
        }
    }
    
    func loginUser() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        if !validateLogin() {
            return
        }
        
        do {
            let user = try await userRepository.login(username: username, password: password)
            currentUser = user
            isAuthenticated = true
        } catch {
            errorMessage = "Invalid username or password"
            showError = true
        }
    }


    
    // Set user as authenticated (for registration success)
    func setAuthenticated() {
    
            self.isAuthenticated = true
        
    }
    
    // Wipe all user data
    func wipeAllData() async {
        do {
            // Delete all users from database
            try await userRepository.deleteAllUsers()
            
            // Clear local state
            users = []
            currentUser = nil
            isAuthenticated = false
            loadUserDetails()
        } catch {
            errorMessage = "Failed to wipe user data: \(error.localizedDescription)"
            showError = true
        }
    }
    
    // Validate login credentials
    private func validateLogin() -> Bool {
        // Reset validation states
        isUsernameValid = !username.isEmpty
        isPasswordValid = !password.isEmpty
        
        // Check if credentials are valid
        if !isUsernameValid || !isPasswordValid {
            errorMessage = "Username and password cannot be empty"
            showError = true
            return false
        }
        
        return true
    }
    
    // Validation of registration data
    private func validateRegistration() -> Bool {
        // Reset validation states
        isUsernameValid = !username.isEmpty
        isPasswordValid = password.count >= 6
        isEmailValid = isValidEmail(email)
        
        // Check all fields
        if !isUsernameValid {
            errorMessage = "Username cannot be empty"
            showError = true
            return false
        }
        
        if !isEmailValid {
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        if !isPasswordValid {
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        return true
    }
    
 // Validation of email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    // Profile update
    func updateProfile(newUsername: String, newEmail: String, currentPassword: String, newPassword: String?) async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        guard let userId = currentUser?.id else {
            errorMessage = "No user logged in"
            showError = true
            throw AuthError.noUserLoggedIn
        }
        
        do {
            // Verify current password
            guard try await userRepository.verifyPassword(userId: userId, password: currentPassword) else {
                errorMessage = "Current password is incorrect"
                showError = true
                throw AuthError.invalidCredentials
            }
            
            // Update profile
            try await userRepository.updateUser(
                userId: userId,
                username: newUsername,
                email: newEmail,
                newPassword: newPassword
            )
            
            // Update local state
            self.username = newUsername
            self.email = newEmail
            if let newPassword = newPassword {
                self.password = newPassword
            }
            
            // Update current user
            currentUser?.username = newUsername
            currentUser?.email = newEmail
            
        } catch AuthError.usernameTaken {
            errorMessage = "Username already taken"
            showError = true
            throw AuthError.usernameTaken
        } catch {
            errorMessage = "Failed to update profile"
            showError = true
            throw error
        }
    }

    // Logout user
    func logout() {
        // Clear user data
        currentUser = nil
        username = ""
        password = ""
        email = ""
        isAuthenticated = false
        showError = false
        registrationSuccess = false
    }
}
