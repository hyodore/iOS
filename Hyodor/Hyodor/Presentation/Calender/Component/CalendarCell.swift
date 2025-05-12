//
//  CalendarCell.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import SwiftUI

struct CalendarCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(foregroundColor)
                .frame(width: 36, height: 36)
                .background(
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color.blue)
                        } else if isToday {
                            Circle()
                                .strokeBorder(Color.blue, lineWidth: 1)
                        }
                    }
                )
            if hasEvents {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 40)
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
}
