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
    @Published var isAuthenticated = false
    @Published var isUsernameValid: Bool = true
    @Published var isPasswordValid: Bool = true
    @Published var isEmailValid: Bool = true
    @Published var isLoading = false
    
    private let userRepository: UserRepository
    private let authController: AuthController
    
    init(userRepository: UserRepository, authController: AuthController) {
        self.userRepository = userRepository
        self.authController = authController
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
                
                username = ""
                email = ""
                password = ""
                registrationSuccess = true
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
        isUsernameValid = true
        isEmailValid = true
        isPasswordValid = true
        
        if username.isEmpty {
            isUsernameValid = false
            errorMessage = "Username cannot be empty"
            showError = true
            return false
        }
        
        if !isValidEmail(email) {
            isEmailValid = false
            errorMessage = "Please enter a valid email address"
            showError = true
            return false
        }
        
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
    
    func setCurrentUser(username: String, email: String, id: UUID) {
        currentUser = User(id: id, username: username, email: email, password: "")
    }
    
    func updateProfile(newUsername: String, newEmail: String, currentPassword: String, newPassword: String?, profilePictureData: Data? = nil) async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let currentUser = authController.currentUser else {
                throw AuthError.noUserLoggedIn
            }
            
            let updatedUser = try await userRepository.updateUser(
                userID: currentUser.id,
                newUsername: newUsername,
                newEmail: newEmail,
                currentPassword: currentPassword,
                newPassword: newPassword,
                profilePictureData: profilePictureData
            )
            
            self.currentUser = updatedUser
            authController.updateCurrentUser(updatedUser)
            
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
    
    func updateProfilePicture(profilePictureData: Data?) async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let currentUser = authController.currentUser else {
                throw AuthError.noUserLoggedIn
            }
            
            let updatedUser = try await userRepository.updateProfilePicture(
                userID: currentUser.id,
                profilePictureData: profilePictureData
            )
            
            self.currentUser = updatedUser
            authController.updateCurrentUser(updatedUser)
            
        } catch {
            errorMessage = "Failed to update profile picture: \(error.localizedDescription)"
            showError = true
            throw error
        }
    }
    
    func updateProfileInfo(
        newUsername: String,
        newEmail: String,
        profilePictureData: Data? = nil
    ) async throws {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            guard let currentUser = authController.currentUser else {
                throw AuthError.noUserLoggedIn
            }
            
            let updatedUser = try await userRepository.updateProfileInfo(
                userID: currentUser.id,
                newUsername: newUsername,
                newEmail: newEmail,
                profilePictureData: profilePictureData
            )
            
            self.currentUser = updatedUser
            authController.updateCurrentUser(updatedUser)
            
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            showError = true
            throw error
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
            showError = true
            throw error
        }
    }
    
    func clearCurrentUser() {
        currentUser = nil
    }
} 