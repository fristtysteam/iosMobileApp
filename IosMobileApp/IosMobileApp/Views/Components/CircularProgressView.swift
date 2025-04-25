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

    private var progressGradient: LinearGradient {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.1)
                .foregroundColor(.gray)

            // Progress circle
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                .fill(progressGradient)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            // Percentage text
            Text(String(format: "%.0f%%", progress * 100))
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(progressGradient)
        }
        .padding(0)
    }
}

//REFERENCED FROM KODECO.COM
