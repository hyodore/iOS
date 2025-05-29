//
//  AbnormalRow.swift
//  Hyodor
//
//  Created by 김상준 on 4/28/25.
//

import SwiftUI

struct HomeAlertRow: View {
    let icon: String
    let title: String
    let date: Date
    var isRecent: Bool = false

    var body: some View {
        HStack{
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.orange)
                    .frame(width: 40, height: 36)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding(.vertical, 2)

                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if isRecent {
                        Text("최신")
                            .font(.caption2)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.14))
                            )
                            .foregroundColor(.blue)
                    }

            Spacer()

            VStack(alignment: .leading){
                Text(date.toKoreanDateString())
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(date.toKoreanTimeString())
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(minWidth: 54, alignment: .trailing)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
        )
        .padding(.vertical, 4)
    }
}
