//
//  ScheduleRow.swift
//  Hyodor
//
//  Created by 김상준 on 4/28/25.
//

import SwiftUI


struct ScheduleRow: View {
    let iconName: String
    let title: String
    let date: String
    let time: String

    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .frame(width: 36, height: 36)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.trailing, 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(time)
                .font(.body)
                .foregroundColor(.black)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
    }
}
