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
                    .foregroundColor(.blue)
            }
            Text(title)
                .font(.footnote)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity,minHeight: 80)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}
