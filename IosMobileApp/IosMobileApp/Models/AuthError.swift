import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case usernameTaken
    case emailTaken
    case networkError
    case noUserLoggedIn
    case invalidPassword
    case userNotFound
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials. Please check your password and try again."
        case .usernameTaken:
            return "Username is already taken. Please choose another one."
        case .emailTaken:
            return "Email is already in use. Please use a different email."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .noUserLoggedIn:
            return "No user is currently logged in."
        case .invalidPassword:
            return "The current password is incorrect."
        case .userNotFound:
            return "User not found."
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
} 