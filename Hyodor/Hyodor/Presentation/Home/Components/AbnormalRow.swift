//
//  AbnormalRow.swift
//  Hyodor
//
//  Created by 김상준 on 4/28/25.
//

import SwiftUI

struct AbnormalRow: View {
    let icon: String
    let title: String
    let date: String
    var isEmoji: Bool = false

    var body: some View {
        HStack {
            if isEmoji {
                Text("😶‍🌫️") // 원하는 이모지로 교체
                    .font(.system(size: 28))
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.orange)
                    .frame(width: 36, height: 36)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }
}

