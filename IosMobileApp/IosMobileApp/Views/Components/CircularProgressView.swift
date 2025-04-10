//
//  CircularProgressView.swift
//  IosMobileApp
//
//  Created by Student on 10/04/2025.
//


import CoreGraphics
import SwiftUICore
import CoreFoundation
import SwiftUI

struct CircularProgressView: View {
    let progress: CGFloat

    // Function to determine the color based on progress
    private var progressColor: Color {
        if progress < 0.3 {
            return .red
        } else if progress < 0.7 {
            return .yellow
        } else {
            return .green
        }
    }

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.1)
                .foregroundColor(.gray)

            // Foreground Progress Circle
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor) // Dynamic color
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text("\(Int(progress * 100))%")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(progressColor)
        }
        .padding(0)
    }
}

//REFERENCED FROM KODECO.COM