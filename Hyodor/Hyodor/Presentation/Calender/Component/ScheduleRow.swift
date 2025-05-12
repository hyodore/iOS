//
//  ScheduleRow.swift
//  Hyodor
//
//  Created by 김상준 on 5/12/25.
//

import SwiftUI

struct ScheduleRow: View {
    let schedule: Schedule
    let onTap: () -> Void

    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 4)
                .cornerRadius(2)
            VStack(alignment: .leading, spacing: 4) {
                Text(schedule.title).font(.headline)
                Text(schedule.date.toKoreanTimeString())
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !schedule.notes.isEmpty {
                    Text(schedule.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 4)
            Spacer()
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
