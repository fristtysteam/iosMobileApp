import SwiftUI
import GRDB

struct AuthView: View {
    @EnvironmentObject var authController: AuthController
    @State private var isLogin = true
    @State private var showUsersList = false
    @State private var viewId = UUID()
    
    var body: some View {
        Group {
            if authController.isAuthenticated {
                ContentView()
                    .environmentObject(authController)
            } else {
                mainContent
            }
        }
        .id(viewId)
        .onReceive(authController.$isAuthenticated) { _ in
            viewId = UUID()
        }
    }
    
    private var mainContent: some View {
        ZStack {
            BlobBackground()
            
            VStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 40)

                if isLogin {
                    // Login Form
                    loginForm
                } else {
                    // Register Form
                    RegisterView(switchView: { isLogin.toggle() })
                }
            }
        }
    }
    
    private var loginForm: some View {
        VStack {
            TextField("Username", text: $authController.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(authController.isUsernameValid ? Color.clear : Color.red, lineWidth: 1)
                )
            
            SecureField("Password", text: $authController.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(authController.isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
                )
        
            Button(action: {
                Task {
                    await authController.loginUser()
                }
            }) {
                if authController.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Login")
                        .fontWeight(.bold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding()
            .disabled(authController.isLoading)

            HStack {
                Text("Do you need to ")
                Button(action: { isLogin.toggle() }) {
                    Text("register")
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                Text("?")
            }
            .padding(.vertical, 10)
            
            HStack {
                Button(action: {
                    showUsersList = true
                }) {
                    Text("View Registered Users")
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {
                    Task {
                        await authController.wipeAllData()
                    }
                }) {
                    Text("Wipe Data")
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            
            if DatabaseManager.isDevelopment {
                Button(action: {
                    // Auto login as test user
                    authController.username = "testuser"
                    authController.password = "password"
                    Task {
                        await authController.loginUser()
                    }
                }) {
                    Text("Dev Login (Skip)")
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                }
                .padding(.top)
            }
        }
        .sheet(isPresented: $showUsersList) {
            UsersListView()
        }
        .alert(isPresented: $authController.showError) {
            Alert(
                title: Text("Error"),
                message: Text(authController.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct BlobBackground: View {
    var body: some View {
        ZStack {
            Color.blue.opacity(0.2)
                .blur(radius: 10)
                .frame(width: 300, height: 250)
                .clipShape(Circle())
                .offset(x: -150, y: -350)
            
            Color.green.opacity(0.2)
                .blur(radius: 10)
                .frame(width: 250, height: 250)
                .clipShape(Circle())
                .offset(x: 150, y: 350)
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        let dbQueue = try! DatabaseQueue()
        let userRepository = UserRepository(dbQueue: dbQueue)
        let goalRepository = GoalRepository(dbQueue: dbQueue)
        let authController = AuthController(userRepository: userRepository, goalRepository: goalRepository)
        AuthView()
            .environmentObject(authController)
    }
}
