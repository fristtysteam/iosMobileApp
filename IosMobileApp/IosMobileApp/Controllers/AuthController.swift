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
    private let goalRepository: GoalRepository
    
    init(userRepository: UserRepository, goalRepository: GoalRepository) {
        self.userRepository = userRepository
        self.goalRepository = goalRepository
        Task {
            await loadUsers()
        }
    }
    
    // Add method to update current user
    func updateCurrentUser(_ user: User) {
        self.currentUser = user
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
            
            // Delete all goals from database
            try await goalRepository.clearAllGoals()
            
            // Clear local state
            users = []
            currentUser = nil
            isAuthenticated = false
            loadUserDetails()
            
            print("Successfully wiped all data")
        } catch {
            errorMessage = "Failed to wipe data: \(error.localizedDescription)"
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
    func updateProfile(
        newUsername: String, 
        newEmail: String, 
        currentPassword: String, 
        newPassword: String?,
        profilePictureData: Data? = nil
    ) async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let updatedUser = try await userRepository.updateUser(
                userID: currentUser?.id ?? UUID(), 
                newUsername: newUsername,
                newEmail: newEmail,
                currentPassword: currentPassword,
                newPassword: newPassword,
                profilePictureData: profilePictureData
            )
            
            currentUser = updatedUser
            return
        } catch AuthError.invalidPassword {
            errorMessage = "Current password is incorrect"
            showError = true
            throw AuthError.invalidPassword
        } catch AuthError.usernameTaken {
            errorMessage = "Username is already taken"
            showError = true
            throw AuthError.usernameTaken
        } catch {
            errorMessage = "Failed to update profile"
            showError = true
            throw error
        }
    }

    // Add a method to refresh the current user data
    func refreshCurrentUser() async {
        guard let userId = currentUser?.id else { return }
        
        do {
            // Fetch the latest user data from the database
            if let refreshedUser = try await userRepository.getUserById(userId) {
                // Update the current user with fresh data
                currentUser = refreshedUser
            }
        } catch {
            print("Failed to refresh user data: \(error)")
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
