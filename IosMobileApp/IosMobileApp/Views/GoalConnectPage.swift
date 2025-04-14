//
//  GoalConnectPage.swift
//  IosMobileApp
//
//  Created by Student on 11/04/2025.
//

import SwiftUI

struct GoalConnectPage: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    HeaderView(title: "Achievr")

    GoalConnectPage()
    BottomBar(addButtonAction: {
        print("Add tapped")
    })
}




