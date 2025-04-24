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
                    
                    Text("Your account has been created successfully.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        // Simply mark user as authenticated in controller
                        authController.setAuthenticated()
                    }) {
                        Text("Continue")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            } else {
                // Registration form
                TextField("Username", text: $authController.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(authController.isUsernameValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                TextField("Email", text: $authController.email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(authController.isEmailValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                SecureField("Password", text: $authController.password)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(authController.isPasswordValid ? Color.gray.opacity(0.3) : Color.red, lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await authController.registerUser()
                    }
                }) {
                    if authController.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Register")
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
                    Text("Already have an account? ")
                        .foregroundColor(.gray)
                    Button(action: switchView) {
                        Text("Login")
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
                .padding(.top, 8)
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
