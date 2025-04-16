//
//  UsersListView.swift
//  IosMobileApp
//
//  Created by Student on 14/04/2025.
//
import SwiftUI
import GRDB

struct UsersListView: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(authController.users) { user in
                    VStack(alignment: .leading) {
                        Text(user.username)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Registered Users")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct UsersListView_Previews: PreviewProvider {
    static var previews: some View {
        let dbQueue = try! DatabaseQueue()
        let userRepository = UserRepository(dbQueue: dbQueue)
        let goalRepository = GoalRepository(dbQueue: dbQueue)
        let authController = AuthController(userRepository: userRepository, goalRepository: goalRepository)
        UsersListView()
            .environmentObject(authController)
    }
}
