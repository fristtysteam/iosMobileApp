import SwiftUI


// Enhanced Registration View with error handling
struct RegisterView: View {
    @EnvironmentObject var authController: AuthController
    var switchView: () -> Void

    var body: some View {
        VStack {
            if authController.registrationSuccess {
                // Success state view
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.green)
                    
                    Text("Registration Successful!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Your account has been created successfully.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        // Simply mark user as authenticated in controller
                        authController.setAuthenticated()
                    }) {
                        Text("Continue")
                            .fontWeight(.bold)
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
                }
                .padding(.vertical, 25)
            } else {
                // Registration form
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 25)
                    
                    VStack(spacing: 16) {
                        // Username field
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 20)
                            TextField("Username", text: $authController.username)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .foregroundColor(.white)
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
                        
                        // Email field
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 20)
                            TextField("Email", text: $authController.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .foregroundColor(.white)
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(authController.isEmailValid ? Color.white.opacity(0.3) : Color.red, lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        
                        // Password field
                        HStack {
                            Image(systemName: "lock")
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 20)
                            SecureField("Password", text: $authController.password)
                                .foregroundColor(.white)
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
                    
                    // Register button
                    Button(action: {
                        Task {
                            await authController.registerUser()
                        }
                    }) {
                        HStack {
                            if authController.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Register")
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

                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.white.opacity(0.8))
                        Button(action: switchView) {
                            Text("Login")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
        }
        .onAppear {
            authController.registrationSuccess = false
        }
        .overlay(
            ToastView(
                message: authController.errorMessage ?? "",
                type: .error,
                isShowing: .init(
                    get: { authController.showError },
                    set: { authController.showError = $0 }
                )
            )
        )
    }
}
