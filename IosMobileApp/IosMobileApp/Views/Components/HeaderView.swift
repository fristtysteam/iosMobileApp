//
//  HeaderView.swift
//  IosMobileApp
//
//  Created by Student on 14/03/2025.
//

import SwiftUI

import SwiftUI

struct HeaderView: View {
    let title: String
    
    @State private var isProfileTapped = false
    
    var body: some View {
        VStack {
            HStack {
                
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color.blue)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    )
                    .onTapGesture {
                        isProfileTapped.toggle()
                        print("Profile tapped: \(isProfileTapped ? "Yes" : "No")")
                    }
                
                Spacer()
                
                
                Text(self.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color.blue)
                
                Spacer()
                
            
                Image(systemName: "bell.fill")
                    .font(.title)
                    .foregroundColor(Color.blue)
                    .onTapGesture {
                        print("Notification tapped!")
                    }
            }
            .padding()
            .background(Color.white)
            .shadow(radius: 10)
            .frame(maxWidth: .infinity, alignment: .top)
            
            Spacer() 
        }
    }
}





#Preview {
    HeaderView(title: "goal getter")
}
