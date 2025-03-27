import SwiftUI

struct AuthView: View {
    @State private var isLogin = true
    
    var body: some View {
        ZStack {
            // Blob background
            BlobBackground()
                .ignoresSafeArea()
            
            VStack {
                if isLogin {
                    LoginView(switchView: { isLogin.toggle() })
                } else {
                    RegisterView(switchView: { isLogin.toggle() })
                }
            }
            .transition(.slide)
        }
    }
}

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    var switchView: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Achievr")
                .font(.largeTitle).bold()
                .padding(.bottom, 10)
                .foregroundColor(Color.blue)
            
            Text("Welcome Back")
                .font(.title).bold()
                .padding(.bottom, 20)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                // Handle login logic here
            }) {
                Text("Login")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Button(action: switchView) {
                Text("Don't have an account? Register")
                    .foregroundColor(.blue)
            }
            .padding()
        }
        .padding()
    }
}

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    var switchView: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Achievr")
                .font(.largeTitle).bold()
                .padding(.bottom, 10)
                .foregroundColor(Color.blue)
            
            Text("Create Account")
                .font(.largeTitle).bold()
                .padding(.bottom, 20)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                // Handle registration logic here
            }) {
                Text("Register")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Button(action: switchView) {
                Text("Already have an account? Login")
                    .foregroundColor(.green)
            }
            .padding()
        }
        .padding()
    }
}

// Blob Background
struct BlobBackground: View {
    var body: some View {
        ZStack {
            // Blue Blob (Top Left)
            Color.blue.opacity(0.2)
                .blur(radius: 10)
                .frame(width: 300, height: 250)
                .clipShape(Circle())
                .offset(x: -150, y: -350)
            
            // Green Blob (Bottom Left)
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
        AuthView()
    }
}
