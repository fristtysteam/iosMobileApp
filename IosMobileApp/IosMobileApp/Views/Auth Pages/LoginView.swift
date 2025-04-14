
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userController: UserController
    @State private var showUsersList = false
    var switchView: () -> Void
   

    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(.top, 40)

            TextField("Username", text: $userController.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(userController.isUsernameValid ? Color.clear : Color.red, lineWidth: 1)
                )
            
            SecureField("Password", text: $userController.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(userController.isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
                )
        
            Button(action: {
                        Task { @MainActor in  // Ensure main thread
                            if userController.loginUser() {
                                // AuthView will handle the transition
                            }
                        }
                    }) {
                if userController.isLoading {
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
            .disabled(userController.isLoading)  // Optional: disable while loading

            Button(action: switchView) {
                Text("Register")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
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
                    userController.wipeAllData()
                }) {
                    Text("Wipe Data")
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            userController.loadUserDetails()
        }
        .sheet(isPresented: $showUsersList) {
            UsersListView(userController: userController)
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
