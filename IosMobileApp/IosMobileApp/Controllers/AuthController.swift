import SwiftUI
import Combine



// All UI updates must happen on the main thread. Since UserController drives the state of UI through @Published properties
// (like isAuthenticated, username, showError), it's
// important those updates happen on the main thread thats why use MainActor
@MainActor
class UserController: ObservableObject {
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
    
    init() {
        loadUsers()
    }
    
  
    func loadUserDetails() {
        username = ""
        password = ""
        email = ""
        registrationSuccess = false
        showError = false
    }

    
  
    func loadUsers() {
        if let data = UserDefaults.standard.data(forKey: "registeredUsers") {
            if let decodedUsers = try? JSONDecoder().decode([User].self, from: data) {
                self.users = decodedUsers
                print("Loaded \(users.count) users")
            }
        }
    }
    
 
    func saveUsers() {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: "registeredUsers")
            print("Saved \(users.count) users")
        }
    }
    
  
    func registerUser() -> Bool {
        // Validate first
        if !validateRegistration() {
            return false
        }
        
        // Check if username already exists
        if users.contains(where: { $0.username == username }) {
            errorMessage = "Username already taken"
            showError = true
            return false
        }
        
        // Create and save new user
        let newUser = User(username: username, email: email, password: password)
        users.append(newUser)
        saveUsers()
        
        // Set success flag
        registrationSuccess = true
        return true
    }
    
    // Authenticate user
    func loginUser() -> Bool {
        guard !isLoading else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
  
        if !validateLogin() {
            return false
        }

        if let _ = users.first(where: { $0.username == username && $0.password == password }) {
            isAuthenticated = true
            return true
        } else {
            errorMessage = "Invalid username or password"
            showError = true
            return false
        }
    }


    
    // Set user as authenticated (for registration success)
    func setAuthenticated() {
    
            self.isAuthenticated = true
        
    }
    
    // Wipe all user data
    func wipeAllData() {
        users = []
        saveUsers()
        UserDefaults.standard.removeObject(forKey: "registeredUsers")
        print("All user data wiped")
    }
    
    // Validate login credentials
    func validateLogin() -> Bool {
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
    func validateRegistration() -> Bool {
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
}
