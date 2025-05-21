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
    @State private var notifications: [NotificationData] = []

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
            .onAppear(perform: loadNotifications) // 알림 데이터 로드
            .onReceive(NotificationCenter.default.publisher(for: .newNotificationReceived)) { _ in
                // 새 알림 수신 시 리스트 업데이트
                loadNotifications()
                print("새 알림 수신, HomeView 리스트 업데이트 완료")
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
                        scheduleButtonFor(index: idx)
                    } else {
                        emptyScheduleRow()
                    }
                }
            }
            .containerStyle()
        }
    }

    @ViewBuilder
    private func scheduleButtonFor(index: Int) -> some View {
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

    private func emptyScheduleRow() -> some View {
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
            if notifications.isEmpty {
                // 알림이 없는 경우 빈 행 표시
                ForEach(0..<4) { _ in
                    emptyAlertRow()
                }
            } else {
                // 최신 4개의 알림 표시
                ForEach(0..<min(notifications.count, 4)) { index in
                    let notification = notifications[index]
                    HomeAlertRow(
                        icon: "shield.lefthalf.fill",
                        title: notification.title,
                        date: notification.receivedDate.formatted(date: .abbreviated, time: .shortened)
                    )
                }
                // 4개 미만일 경우 빈 행으로 채움
                if notifications.count < 4 {
                    ForEach(notifications.count..<4) { _ in
                        emptyAlertRow()
                    }
                }
            }
        }
        .containerStyle()
    }

    private func emptyAlertRow() -> some View {
        HomeAlertRow(
            icon: "shield.lefthalf.fill",
            title: "",
            date: ""
        )
        .opacity(0)
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

    // MARK: - Data Loading

    private func loadNotifications() {
        if let savedNotifications = UserDefaults.standard.array(forKey: "notifications") as? [Data] {
            let decoder = JSONDecoder()
            let loadedNotifications = savedNotifications.compactMap { data in
                do {
                    return try decoder.decode(NotificationData.self, from: data)
                } catch {
                    print("Failed to decode notification data: \(error)")
                    return nil
                }
            }
            // 최신 순으로 정렬 (receivedDate 기준 내림차순)
            notifications = loadedNotifications.sorted(by: { $0.receivedDate > $1.receivedDate })
            print("HomeView에 로드된 알림 데이터: \(notifications.count)개")
        } else {
            notifications = []
            print("UserDefaults에 저장된 알림 데이터가 없습니다.")
        }
    }
}
