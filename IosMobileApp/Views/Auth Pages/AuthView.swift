private var loginForm: some View {
    VStack {
        VStack(spacing: 16) {
            TextField("Username", text: $authController.username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(authController.isUsernameValid ? Color.clear : Color.red, lineWidth: 1)
                )
                .padding(.horizontal)
        
            SecureField("Password", text: $authController.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(authController.isPasswordValid ? Color.clear : Color.red, lineWidth: 1)
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