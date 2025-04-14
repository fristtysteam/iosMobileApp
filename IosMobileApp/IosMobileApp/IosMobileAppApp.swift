import SwiftUI

@main
struct IosMobileAppApp: App {
    
    
    @StateObject private var userController = UserController()
    var body: some Scene {
        WindowGroup {
            AuthView().environmentObject(userController)
        }
    }
}
