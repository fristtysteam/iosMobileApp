import SwiftUI
import GRDB

struct AuthView: View {
    @EnvironmentObject var authController: AuthController
    @State private var isLogin = true
    @State private var showUsersList = false
    @State private var viewId = UUID()
    @State private var isKeyboardVisible = false
    
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
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            isKeyboardVisible = false
        }
    }
    
    private var mainContent: some View {
        ZStack {
            // Improved background with subtle animation
            AnimatedGradientBackground()
            
            ScrollView {
                VStack {
                    // Logo and title with better spacing
                    VStack(spacing: 16) {
                        Image("AchievrLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .padding(.top, isKeyboardVisible ? 20 : 60)
                        
                        Text("Achievr")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 2)
                    }
                    .padding(.bottom, 30)
                    
                    // Form container with card-like appearance
                    VStack(spacing: 0) {
                        if isLogin {
                            loginForm
                        } else {
                            RegisterView(switchView: { isLogin.toggle() })
                        }
                    }
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    
                    // Bottom actions with better spacing
                    if !isKeyboardVisible {
                        VStack(spacing: 20) {
                            HStack {
                                Text("Do you need to ")
                                    .foregroundColor(.white.opacity(0.8))
                                Button(action: { isLogin.toggle() }) {
                                    Text("register?")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.top, 25)
                            
                            if DatabaseManager.isDevelopment {
                                Button(action: {
                                    authController.username = "testuser"
                                    authController.password = "password"
                                    Task {
                                        await authController.loginUser()
                                    }
                                }) {
                                    Text("Dev Login (Skip)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(8)
                                }
                            }
                            
                            HStack(spacing: 20) {
                                Button(action: { showUsersList = true }) {
                                    Text("View Users")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Button(action: {
                                    Task {
                                        await authController.wipeAllData()
                                    }
                                }) {
                                    Text("Wipe Data")
                                        .font(.caption)
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding(.top, 20)
                    }
                }
                .padding(.bottom, isKeyboardVisible ? 250 : 0)
            }
            
            if authController.isLoading {
                LoadingOverlay()
            }
        }
        .sheet(isPresented: $showUsersList) {
            UsersListView()
                .preferredColorScheme(.dark)
        }
        .alert(isPresented: $authController.showError) {
            Alert(
                title: Text("Error"),
                message: Text(authController.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private var loginForm: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.top, 25)
            
            VStack(spacing: 16) {
                // Improved text field with icon and better validation
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 20)
                    TextField("Username", text: $authController.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(authController.isUsernameValid ? Color.white.opacity(0.3) : Color.red, lineWidth: 1)
                )
                .padding(.horizontal, 20)
                
                // Improved secure field with icon
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: 20)
                    SecureField("Password", text: $authController.password)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(authController.isPasswordValid ? Color.white.opacity(0.3) : Color.red, lineWidth: 1)
                )
                .padding(.horizontal, 20)
            }
            .padding(.top, 10)
            
            // Improved login button with animation
            Button(action: {
                Task {
                    await authController.loginUser()
                }
            }) {
                HStack {
                    if authController.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Login")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            .disabled(authController.isLoading)
            
            Spacer()
                .frame(height: 20)
        }
    }
}

struct AnimatedGradientBackground: View {
    @State private var gradientStart = UnitPoint(x: 0, y: 0)
    @State private var gradientEnd = UnitPoint(x: 0, y: 2)
    
    let gradientColors = [
        Color(red: 0.2, green: 0.4, blue: 0.8),
        Color(red: 0.4, green: 0.2, blue: 0.8),
        Color(red: 0.8, green: 0.2, blue: 0.4)
    ]
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: gradientStart,
            endPoint: gradientEnd
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 8.0).repeatForever(autoreverses: true)) {
                self.gradientStart = UnitPoint(x: 1, y: -1)
                self.gradientEnd = UnitPoint(x: 0, y: 1)
            }
        }
    }
}

struct LoadingOverlay: View {
    var body: some View {
        Color.black.opacity(0.5)
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
                .padding(30)
                .background(Color.black.opacity(0.7))
                .cornerRadius(15)
            )
    }
}
