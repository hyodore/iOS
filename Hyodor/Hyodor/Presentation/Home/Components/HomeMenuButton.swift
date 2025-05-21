//
//  HomeMenuButton.swift
//  Hyodor
//
//  Created by 김상준 on 4/28/25.
//

import SwiftUI

struct HomeMenuButton: View {
    let imageName: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
        )
    }
}

