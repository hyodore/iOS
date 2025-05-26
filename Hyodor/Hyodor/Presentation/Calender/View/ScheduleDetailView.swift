//
//  ScheduleDetailView.swift
//  Hyodor
//
//  Created by 김상준 on 5/12/25.
//

import SwiftUI

struct ScheduleDetailView: View {
    let schedule: Schedule
    let onDelete: () -> Void

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(schedule.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Image(systemName: "calendar")
                        Text(schedule.date.toKoreanDateString() + " " + schedule.date.toKoreanTimeString())
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if !schedule.notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("메모")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(schedule.notes)
                                .font(.body)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer() 
            Button(role: .destructive, action: {
                onDelete()
            }) {
                Label("일정 삭제", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(Color.red.opacity(0.1))
            .cornerRadius(8)
            .padding()
        }
    }
}
