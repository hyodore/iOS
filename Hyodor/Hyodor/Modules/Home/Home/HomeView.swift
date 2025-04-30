//
//  HomeView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

struct HomeView: View {
    @State var viewModel: HomeViewModel
    @State var coordinator: HomeCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            VStack {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("HYODOR")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Button {
                            viewModel.didTapCalendar()
                        } label: {
                            HomeMenuButton(imageName: "calendar", title: "캘린더")
                        }
                        Button {
                            viewModel.didTapSharedAlbum()
                        } label: {
                            HomeMenuButton(imageName: "camera", title: "공유 앨범")
                        }
                    }
                }
                .padding()
                VStack(alignment: .leading, spacing: 16) {
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
                            viewModel.didTapAlert()
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
            }
            .navigationDestination(for: HomeCoordinator.HomeRoute.self) { route in
                switch route {
                case .calendar:
                    CalendarView()
                case .sharedAlbum:
                    SharedAlbumView()
                case .Alert:
                    AlertView()
                }
            }
        }
    }
}

#Preview {
    let coordinator = HomeCoordinator()
    HomeView(viewModel: HomeViewModel(coordinator: coordinator), coordinator: coordinator)
}
