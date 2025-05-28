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
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        return formatter
    }()

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
            ZStack(alignment: .bottom) {
                // 메인 콘텐츠
                ScrollView {
                    VStack(spacing: 0) {
                        // 🔥 토스 스타일 헤더 카드
                        TossDetailHeaderCard(
                            title: schedule.title,
                            date: schedule.date,
                            dateFormatter: dateFormatter,
                            timeFormatter: timeFormatter
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                        // 🔥 메모 섹션 (있을 경우만)
                        if let notes = schedule.notes, !notes.isEmpty {
                            TossDetailNotesCard(notes: notes)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                        }

                        // 🔥 하단 여백 (버튼 공간 확보)
                        Spacer(minLength: 120)
                    }
                }

                // 🔥 하단 고정 삭제 버튼
                TossDeleteButton(
                    onDelete: {
                        showingDeleteAlert = true
                    }
                )
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .alert("일정을 삭제하시겠어요?", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) {}
                Button("삭제", role: .destructive) {
                    onDelete()
                    dismiss()
                }
            } message: {
                Text("삭제된 일정은 복구할 수 없습니다.")
            }

    }
}

struct TossDetailHeaderCard: View {
    let title: String
    let date: Date
    let dateFormatter: DateFormatter
    let timeFormatter: DateFormatter

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("일정")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 20)

            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
                .padding(.horizontal, 24)

            VStack(alignment: .leading, spacing: 16) {
                Text("일시")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "calendar")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 20)

                        Text(dateFormatter.string(from: date))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "clock")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(width: 20)

                        Text(timeFormatter.string(from: date))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
}

struct TossDetailNotesCard: View {
    let notes: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("메모")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            Text(notes)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
}

struct TossDeleteButton: View {
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground).opacity(0),
                    Color(.systemGroupedBackground).opacity(0.8),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 20)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 1)

                Button(action: onDelete) {
                    HStack(spacing: 8) {
                        Image(systemName: "trash")
                            .font(.system(size: 16, weight: .medium))

                        Text("일정 삭제")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                }
                .background(Color(.systemBackground))
            }
        }
    }
}

#Preview(body: {
    ScheduleDetailView(
        schedule: Schedule(
            id: UUID(),
            title: "팀 미팅",
            date: Date(),
            notes: "프로젝트 진행 상황 공유 및 다음 주 계획 논의"
        ),
        onDelete: {}
    )
})
