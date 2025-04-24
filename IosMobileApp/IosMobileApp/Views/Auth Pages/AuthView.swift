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
                Image("AchievrLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding(.top, 40)
                
                Text("Achievr")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)

                if isLogin {
                    // Login Form
                    loginForm
                } else {
                    // Register Form
                    RegisterView(switchView: { isLogin.toggle() })
                }
            }
            
            if authController.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Logging in...")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    )
            }
        }
    }
    
    private var loginForm: some View {
        VStack {
            VStack(spacing: 16) {
                TextField("Username", text: $authController.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(authController.isUsernameValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
                    .padding(.horizontal)
            
                SecureField("Password", text: $authController.password)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(authController.isPasswordValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
                    .padding(.horizontal)
            }
        
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
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Shared gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.4),
                    Color.purple.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
            .offset(y: -100)
            .blur(radius: 30)
            .mask {
                ZStack {
                    // Top left mask
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 150,
                            bottomLeading: 150,
                            bottomTrailing: 0,
                            topTrailing: 160
                        )
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(64))
                    .offset(x: -150, y: -380)
                    .opacity(isAnimating ? 1 : 0)
                    
                    // Bottom right mask
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 150,
                            bottomLeading: 150,
                            bottomTrailing: 0,
                            topTrailing: 150
                        )
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(240))
                    .offset(x: 150, y: 400)
                    .opacity(isAnimating ? 1 : 0)
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeIn(duration: 2.0)) {
                isAnimating = true
            }
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
