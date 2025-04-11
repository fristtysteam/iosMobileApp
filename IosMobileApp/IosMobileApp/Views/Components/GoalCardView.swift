//
//  GoalCardView.swift
//  IosMobileApp
//
//  Created by Student on 10/04/2025.
//


//
//  GoalCardView.swift
//  IosMobileApp
//
//  Created by Student on 31/03/2025.
//

import SwiftUICore

struct GoalCardView: View {
    let title: String
    let description: String?
    let progress: Double
    let category: String?
    let deadline: Date?
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(description ?? "No description")
                .frame(maxWidth: 350, alignment: .leading)
                .font(.subheadline)
                .lineLimit(1)
                .foregroundColor(.gray)
            
            
            HStack {
                CircularProgressView(progress: progress * 0.01)
                    .frame(width: 75, height: 75)
                
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                Spacer()
                
                
                
                VStack {
                    VStack {
                        Text("Category")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text(category ?? "N/A")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    
                    VStack {
                        Text("Deadline")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(deadline?.formatted(.dateTime.year().month().day()) ?? "N/A")
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding()
    }
    
}


