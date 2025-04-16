import SwiftUI


// Enhanced Registration View with error handling
struct RegisterView: View {
    @EnvironmentObject var authController: AuthController
    var switchView: () -> Void

    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 40)

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
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(authController.isUsernameValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
                TextField("Email", text: $authController.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(authController.isEmailValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $authController.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(authController.isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
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

                Button(action: switchView) {
                    Text("Login")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
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
