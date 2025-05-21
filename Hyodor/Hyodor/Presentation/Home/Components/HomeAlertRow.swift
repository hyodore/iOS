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
    let date: Date // Date 타입으로 변경하여 포맷팅 함수 사용
    var isEmoji: Bool = false
    var isRecent: Bool = false // 최신 알림 여부를 표시하기 위한 플래그

    private var dateString: String {
        date.toKoreanDateString()
    }

    private var timeString: String {
        date.toKoreanTimeString()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            // 아이콘 부분
            if isEmoji {
                Text("😶‍🌫️") // 원하는 이모지로 교체
                    .font(.system(size: 28))
                    .frame(width: 40, height: 36)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .padding(.vertical, 2)
            } else {
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
            }

            // 텍스트 부분
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
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
                }
                Text(dateString)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
            // 시간 표시 추가
            Text(timeString)
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
