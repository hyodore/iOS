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
    @State private var animateOnAppear: Bool = false

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                Color(.systemBackground).ignoresSafeArea() // 밝고 깔끔한 배경

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        contentSection
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden) // 스크롤바 숨김
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("HYODOR")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                }
            }
            .sheet(item: $selectedSchedule) { schedule in
                scheduleDetailSheet(for: schedule)
            }
            .navigationDestination(for: HomeCoordinator.HomeRoute.self) { route in
                destinationView(for: route)
            }
            .onAppear {
                loadNotifications()
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateOnAppear = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .newNotificationReceived)) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    loadNotifications()
                }
                print("새 알림 수신, HomeView 리스트 업데이트 완료")
            }
        }
    }

    // MARK: - UI Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // "HYODOR" 텍스트는 NavigationBar로 이동했으므로 제거
            HStack(spacing: 16) {
                Button { viewModel.didTapCalendar() } label: {
                    HomeMenuButton(imageName: "calendar", title: "캘린더")
                        .scaleEffect(animateOnAppear ? 1.0 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateOnAppear)
                }
                Button { viewModel.didTapSharedAlbum() } label: {
                    HomeMenuButton(imageName: "camera", title: "공유 앨범")
                        .scaleEffect(animateOnAppear ? 1.0 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: animateOnAppear)
                }
            }
            .padding(.horizontal, 20) // 좌우 여백 고정
        }
    }

    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            scheduleSection
            alertSection
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Schedule Section

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "부모님 일정")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            VStack(spacing: 8) {
                ForEach(0..<4) { idx in
                    if idx < viewModel.displayedEvents.count {
                        scheduleButtonFor(index: idx)
                            .offset(y: animateOnAppear ? 0 : 20)
                            .opacity(animateOnAppear ? 1 : 0)
                            .animation(.easeInOut(duration: 0.4).delay(Double(idx) * 0.1), value: animateOnAppear)
                    } else {
                        emptyScheduleRow()
                    }
                }
            }
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader(title: "이상현상 리스트")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Button("전체 보기") {
                    viewModel.didTapAlert()
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.blue)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue.opacity(0.1))
                )
            }

            alertRowsContainer
        }
    }

    private var alertRowsContainer: some View {
        VStack(spacing: 8) {
            if notifications.isEmpty {
                // 알림이 없는 경우 빈 행 표시
                ForEach(0..<4) { _ in
                    emptyAlertRow()
                }
            } else {
                // 최신 4개의 알림 표시
                ForEach(0..<min(notifications.count, 4)) { index in
                    let notification = notifications[index]
                    Button {
                        // 알림 클릭 시 상세 뷰로 이동 (AlertView 또는 별도 상세 뷰로 이동 가능)
                        // coordinator.path.append(HomeCoordinator.HomeRoute.Alert) // 예시
                    } label: {
                        HomeAlertRow(
                            icon: "shield.lefthalf.fill",
                            title: notification.title,
                            date: notification.receivedDate,
                            isRecent: index == 0
                        )
                    }
                    .buttonStyle(.plain)
                    .offset(y: animateOnAppear ? 0 : 20)
                    .opacity(animateOnAppear ? 1 : 0)
                    .animation(.easeInOut(duration: 0.4).delay(Double(index + 4) * 0.1), value: animateOnAppear)
                }
                // 4개 미만일 경우 빈 행으로 채움
                if notifications.count < 4 {
                    ForEach(notifications.count..<4) { _ in
                        emptyAlertRow()
                    }
                }
            }
        }
    }

    private func emptyAlertRow() -> some View {
        HomeAlertRow(
            icon: "shield.lefthalf.fill",
            title: "",
            date: Date()
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
