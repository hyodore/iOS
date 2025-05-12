//
//  ScheduleRow.swift
//  Hyodor
//
//  Created by 김상준 on 4/28/25.
//

import SwiftUI

struct EventRow: View {
    let title: String
    let date: Date
    let time: String
    let isPast: Bool
    let isToday: Bool

    private var dateString: String {
        date.toKoreanDateString()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
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

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if isPast {
                        Text("시간 지남")
                            .font(.caption2)
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.14))
                            )
                            .foregroundColor(.red)
                    }
                }
                Text(dateString)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(time)
                .font(.system(size: 16, weight: .light, design: .rounded))
                .foregroundColor(.primary)
                .frame(minWidth: 54, alignment: .trailing)
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
