//
//  HomeView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    
    @State var coordinator: HomeCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                Color(red: 0.976, green: 0.976, blue: 0.976).ignoresSafeArea()
                VStack {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("HYODOR")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        HStack {
                            Button { viewModel.didTapCalendar() } label: {
                                HomeMenuButton(imageName: "calendar", title: "캘린더")
                            }
                            Button { viewModel.didTapSharedAlbum() } label: {
                                HomeMenuButton(imageName: "camera", title: "공유 앨범")
                            }
                        }
                    }
                    .padding()

                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "부모님 일정")
                        VStack(spacing: 0) {
                            ForEach(0..<4) { idx in
                                if idx < viewModel.events.count {
                                    let event = viewModel.events[idx]
                                    ScheduleRow(
                                        iconName: "calendar",
                                        title: event.title,
                                        date: event.date.toKoreanDateString(),
                                        time: event.date.toKoreanTimeString()
                                    )
                                } else {
                                    ScheduleRow(iconName: "calendar", title: "", date: "", time: "")
                                        .opacity(0)
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(8)

                        HStack {
                            SectionHeader(title: "이상현상 리스트")
                            Spacer()
                            Button("전체 보기") { viewModel.didTapAlert() }
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        VStack(spacing: 0) {
                            AbnormalRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 11일 21시 30분")
                            AbnormalRow(icon: "face.smiling", title: "바닥에 넘어짐", date: "4월 11일 21시 30분", isEmoji: true)
                            AbnormalRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 10일 21시 30분")
                            AbnormalRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 10일 21시 30분")
                        }
                        .background(Color.white)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationDestination(for: HomeCoordinator.HomeRoute.self) { route in
                switch route {
                case .calendar:
                    CalendarView(viewModel: viewModel)
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

extension Date {
    func toKoreanDateString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        return formatter.string(from: self)
    }
    func toKoreanTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}
