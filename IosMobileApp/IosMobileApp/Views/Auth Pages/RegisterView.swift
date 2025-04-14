import SwiftUI


// Enhanced Registration View with error handling
struct RegisterView: View {
    @EnvironmentObject var userController: UserController
        var switchView: () -> Void

    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 40)

            if userController.registrationSuccess {
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
                        userController.setAuthenticated()
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
                TextField("Username", text: $userController.username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(userController.isUsernameValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
                TextField("Email", text: $userController.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(userController.isEmailValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $userController.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(userController.isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
                    )
                
                Button(action: {
                    userController.registerUser()
                    // Note: Registration success is handled by observing registrationSuccess
                }) {
                    Text("Register")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

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
            userController.registrationSuccess = false
        }
        .overlay(
            ZStack {
                if userController.showError {
                    VStack {
                        Spacer()
                        ToastView(message: userController.errorMessage)
                            .padding(.bottom, 20)
                    }
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                userController.showError = false
                            }
                        }
                    }
                }
            }
        )
    }
}
