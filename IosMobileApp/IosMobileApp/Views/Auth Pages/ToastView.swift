//
//  ToastView.swift
//  IosMobileApp
//
//  Created by Student on 14/04/2025.
//
import SwiftUI

struct ToastView: View {
    var message: String
    var isError: Bool = true
    
    var body: some View {
        Text(message)
            .padding()
            .background(isError ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}
