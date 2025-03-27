//
//  addGoalPage.swift
//  IosMobileApp
//
//  Created by Student on 24/03/2025.
//

import SwiftUI

struct addGoalPage: View {
    
    var body: some View {

        NavigationLink(destination: ContentView()) {
            
        }

        Text("Create a Goal");
        MultiDatePicker(/*@START_MENU_TOKEN@*/"Label"/*@END_MENU_TOKEN@*/, selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Binding<Set<DateComponents>>@*/.constant([])/*@END_MENU_TOKEN@*/).frame(height: 330)
        Form {
            /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Content")/*@END_MENU_TOKEN@*/
            Text("Goal name")
            Text("Category")
            Text("Description")
            
        }
        
        
    }
}

#Preview {
    addGoalPage()
}
