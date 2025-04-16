import Foundation
import SwiftUI

@MainActor
class UserController: ObservableObject {
    @Published var currentUser: User?
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var email: String = ""
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var registrationSuccess: Bool = false
    @Published var users: [User] = []
    @Published var isAuthenticated = false
    @Published var isUsernameValid: Bool = true
    @Published var isPasswordValid: Bool = true
    @Published var isEmailValid: Bool = true
    @Published var isLoading = false
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func setAuthenticated() {
        self.isAuthenticated = true
    }
    
    @MainActor
    func registerUser() {
        guard validateInputs() else { return }
        
        Task {
            do {
                let user = try await userRepository.register(
                    username: username,
                    email: email,
                    password: password
                )
                
                // Clear form fields
                username = ""
                email = ""
                password = ""
                
                // Set success state
                registrationSuccess = true
                
                // Set current user
                setCurrentUser(username: user.username, email: user.email, id: user.id)
                
            } catch let error as AuthError {
                errorMessage = error.localizedDescription
                showError = true
            } catch {
                errorMessage = AuthError.unknown.localizedDescription
                showError = true
            }
        }
    }
    
    private func validateInputs() -> Bool {
        // Reset validation states
        isUsernameValid = true
        isEmailValid = true
        isPasswordValid = true
        
        // Validate username
        if username.isEmpty {
            isUsernameValid = false
            errorMessage = "Username cannot be empty"
            showError = true
            return false
        }
        
        // Validate email
        if !isValidEmail(email) {
            isEmailValid = false
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
        // Validate password
        if password.count < 6 {
            isPasswordValid = false
            errorMessage = "Password must be at least 6 characters"
            showError = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func loadUsers() async {
        // ... existing code ...
    }
    
    func setCurrentUser(username: String, email: String, id: UUID) {
        currentUser = User(id: id, username: username, email: email, password: "")
    }
    
    func updateProfile(newUsername: String, newEmail: String, currentPassword: String, newPassword: String?) async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let currentUser = self.currentUser else {
                throw AuthError.noUserLoggedIn
            }
            
            // Verify current password
            guard try await userRepository.verifyPassword(userId: currentUser.id, password: currentPassword) else {
                throw AuthError.invalidCredentials
            }
            
            // Check if new username is taken (if different from current)
            if newUsername != currentUser.username {
                if try await userRepository.isUsernameTaken(newUsername) {
                    throw AuthError.usernameTaken
                }
            }
            
            // Update user information
            try await userRepository.updateUser(
                userId: currentUser.id,
                username: newUsername,
                email: newEmail,
                newPassword: newPassword
            )
            
            // Update current user information
            self.currentUser?.username = newUsername
            self.currentUser?.email = newEmail
            if let newPassword = newPassword {
                self.currentUser?.password = newPassword
            }
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            showError = true
            throw error
        } catch {
            errorMessage = AuthError.unknown.localizedDescription
            showError = true
            throw AuthError.unknown
        }
    }
    
    func clearCurrentUser() {
        currentUser = nil
    }
} 