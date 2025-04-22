//
//  BadgeView.swift
//  IosMobileApp
//
//  Created by Student on 22/04/2025.
//


import SwiftUI

struct BadgeView: View {
    let badge: Badge
    let isEarned: Bool
    let size: CGFloat

    init(badge: Badge, isEarned: Bool, size: CGFloat = 60) {
        self.badge = badge
        self.isEarned = isEarned
        self.size = size
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: badge.imageName)
                .font(.system(size: size * 0.6))
                .frame(width: size, height: size)
                .background(isEarned ? Color.yellow : Color.gray.opacity(0.2))
                .foregroundColor(isEarned ? .white : .gray)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(isEarned ? Color.yellow : Color.gray, lineWidth: 2)
                )

            Text(badge.name)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
                .frame(width: size + 20)
                .multilineTextAlignment(.center)

            if !isEarned {
                Text("Complete \(badge.goalCountRequired) goals")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: size + 30)
    }
}
