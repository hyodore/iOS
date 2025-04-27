//
//  HomeView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack{
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("HYODOR")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack(spacing: 16) {
                        NavigationLink(destination: CalendarView()) {
                            HomeMenuButton(imageName: "calendar", title: "캘린더")
                        }
                        NavigationLink(destination: SharedAlbumView()) {
                            HomeMenuButton(imageName: "camera", title: "공유 앨범")
                        }
                    }
                }
                .padding()

                VStack(alignment: .leading, spacing: 24) {
                    // 부모님 일정
                    SectionHeader(title: "부모님 일정")
                    VStack(spacing: 0) {
                        ScheduleRow(iconName: "calendar", title: "회의 일정", date: "9월 21일", time: "10:00 AM")
                        Divider().padding(.leading, 60)
                        ScheduleRow(iconName: "calendar", title: "회의 일정", date: "9월 21일", time: "10:00 AM")
                        Divider().padding(.leading, 60)
                        ScheduleRow(iconName: "calendar", title: "회의 일정", date: "9월 21일", time: "10:00 AM")
                        Divider().padding(.leading, 60)
                        ScheduleRow(iconName: "calendar", title: "가족 저녁 식사", date: "9월 25일", time: "7:00 PM")
                    }
                    .background(Color.white)
                    .cornerRadius(8)

                    // 이상현상 리스트
                    HStack {
                        SectionHeader(title: "이상현상 리스트")
                        Spacer()
                        Button("전체 보기") {
                            // 전체 보기 액션
                        }
                        .font(.footnote)
                        .foregroundColor(.gray)
                    }
                    VStack(spacing: 0) {
                        AbnormalRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 11일 21시 30분")
                        Divider().padding(.leading, 40)
                        AbnormalRow(icon: "face.smiling", title: "바닥에 넘어짐", date: "4월 11일 21시 30분", isEmoji: true)
                        Divider().padding(.leading, 40)
                        AbnormalRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 10일 21시 30분")
                        Divider().padding(.leading, 40)
                        AbnormalRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 10일 21시 30분")
                    }
                    .background(Color.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top, 24)
            }
        }
    }
}

// MARK: - 컴포넌트 뷰

struct HomeMenuButton: View {
    let imageName: String
    let title: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.blue)
            }
            Text(title)
                .font(.footnote)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity,minHeight: 90)
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.bottom, 4)
    }
}

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

#Preview {
    HomeView()
}
