//
//  ScheduleRow.swift
//  Hyodor
//
//  Created by 김상준 on 4/28/25.
//

import SwiftUI

struct HomeScheduleRow: View {
    let title: String
    let date: Date
    let time: String
    let isToday: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text(date.dDayText(for: date))
                .font(.system(size: 14,design: .rounded))
                .frame(width: 40, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isToday ? Color.blue : Color(.systemGray5))
                        .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
                )
                .foregroundColor(isToday ? .white : .blue)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isToday ? Color.blue : Color(.systemGray4), lineWidth: 1)
                )
                .padding(.vertical, 2)

            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)

            Spacer()
            VStack(alignment: .leading){
                Text(date.toKoreanDateString())
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(time)
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
