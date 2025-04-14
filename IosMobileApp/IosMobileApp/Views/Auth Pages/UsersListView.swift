//
//  UsersListView.swift
//  IosMobileApp
//
//  Created by Student on 14/04/2025.
//
import SwiftUI

struct UsersListView: View {
    @ObservedObject var userController: UserController
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(userController.users) { user in
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
