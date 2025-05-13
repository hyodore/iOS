//
//  HomeView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeVM
    @State var coordinator: HomeCoordinator
    @State private var selectedSchedule: Schedule? = nil

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                Color(red: 0.976, green: 0.976, blue: 0.976).ignoresSafeArea()

                VStack {
                    headerSection
                    contentSection
                }
            }
            .sheet(item: $selectedSchedule) { schedule in
                scheduleDetailSheet(for: schedule)
            }
            .navigationDestination(for: HomeCoordinator.HomeRoute.self) { route in
                destinationView(for: route)
            }
        }
    }

    // MARK: - UI Sections

    private var headerSection: some View {
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
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            scheduleSection
            alertSection
        }
        .padding(.horizontal)
    }

    // MARK: - Schedule Section

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "부모님 일정")

            VStack(spacing: 0) {
                ForEach(0..<4) { idx in
                    if idx < viewModel.displayedEvents.count {
                        createScheduleButton(for: idx)
                    } else {
                        createEmptyScheduleRow()
                    }
                }
            }
            .background(Color.white)
            .cornerRadius(8)
        }
    }

    @ViewBuilder
    private func createScheduleButton(for index: Int) -> some View {
        let event = viewModel.displayedEvents[index]
        let calendar = Calendar.current
        let now = Date()
        let isToday = calendar.isDate(event.date, inSameDayAs: now)
        let isPast: Bool = {
            if isToday {
                return event.date < now
            } else {
                return event.date < calendar.startOfDay(for: now)
            }
        }()

        Button {
            selectedSchedule = event
        } label: {
            HomeScheduleRow(
                title: event.title,
                date: event.date,
                time: event.date.toKoreanTimeString(),
                isPast: isPast,
                isToday: isToday
            )
        }
        .buttonStyle(.plain)
    }

    private func createEmptyScheduleRow() -> some View {
        HomeScheduleRow(
            title: "",
            date: Date(),
            time: "",
            isPast: false,
            isToday: false
        )
        .opacity(0)
    }

    // MARK: - Alert Section

    private var alertSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                SectionHeader(title: "이상현상 리스트")
                Spacer()
                Button("전체 보기") { viewModel.didTapAlert() }
                    .font(.footnote)
                    .foregroundColor(.gray)
            }

            alertRowsContainer
        }
    }

    private var alertRowsContainer: some View {
        VStack(spacing: 0) {
            HomeAlertRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 11일 21시 30분")
            HomeAlertRow(icon: "face.smiling", title: "바닥에 넘어짐", date: "4월 11일 21시 30분", isEmoji: true)
            HomeAlertRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 10일 21시 30분")
            HomeAlertRow(icon: "shield.lefthalf.fill", title: "바닥에 넘어짐", date: "4월 10일 21시 30분")
        }
        .background(Color.white)
        .cornerRadius(8)
    }

    // MARK: - Navigation

    private func scheduleDetailSheet(for schedule: Schedule) -> some View {
        NavigationStack {
            ScheduleDetailView(
                schedule: schedule,
                onDelete: {
                    Task {
                        await viewModel.calendarVM.removeEvent(schedule)
                        selectedSchedule = nil
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        selectedSchedule = nil
                    }
                }
            }
            .navigationTitle("일정 상세")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func destinationView(for route: HomeCoordinator.HomeRoute) -> some View {
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
