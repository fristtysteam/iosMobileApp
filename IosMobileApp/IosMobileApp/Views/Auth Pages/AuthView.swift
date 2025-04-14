import SwiftUI


struct AuthView: View {
    @StateObject private var userController = UserController()
    @State private var isLogin = true
    @State private var viewId = UUID()
    
    var body: some View {
        Group {
            if userController.isAuthenticated {
                ContentView()
                    .environmentObject(userController)  // Pass controller down
            } else {
                authContent
            }
        }
        .id(viewId)  // Force full view recreation on auth change
        .onReceive(userController.$isAuthenticated) { _ in
            viewId = UUID()  // Change identity when auth state changes
        }
    }
    
    private var authContent: some View {
        ZStack {
            BlobBackground()
            
            VStack {
                if isLogin {
                    LoginView(switchView: { isLogin.toggle() })
                        .environmentObject(userController)
                } else {
                    RegisterView(switchView: { isLogin.toggle() })
                        .environmentObject(userController)
                }
            }
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
        AuthView()
    }
}
