//
//  GoalConnectPage.swift
//  IosMobileApp
//
//  Created by Student on 11/04/2025.
//

import SwiftUI

struct GoalConnectPage: View {
    @State private var showingAddGoal = false
    @State private var showingGoalDetails = false
    
    // Sample goal data using your actual Goal model
    private let sampleGoal: Goal = {
        let calendar = Calendar.current
        let deadline = calendar.date(byAdding: .day, value: 30, to: Date()) // 30 days from now
        return Goal(
            title: "Learn SwiftUI",
            description: "Master SwiftUI fundamentals",
            category: "Education",
            deadline: deadline,
            progress: 0.25,
            isCompleted: false,
            progressDiary: ["Started learning", "Completed basic views"]
        )
    }()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Goal Connect")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            // Option to go to Add Goal
            Button(action: {
                showingAddGoal = true
            }) {
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 50))
                    Text("Add New Goal")
                        .font(.title2)
                }
                .foregroundColor(.blue)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            // Option to go to Goal Details
            Button(action: {
                showingGoalDetails = true
            }) {
                VStack {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.system(size: 50))
                    Text("View Goal Details")
                        .font(.title2)
                }
                .foregroundColor(.green)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.1))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationDestination(isPresented: $showingAddGoal) {
            AddGoalView()
        }
        .navigationDestination(isPresented: $showingGoalDetails) {
            GoalDetailsView(goal: sampleGoal)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    HeaderView(title: "Achievr")


    NavigationStack {
        GoalConnectPage()
    }


}
