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
    @State private var animateOnAppear: Bool = false

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        contentSection
                    }
                    .padding(.bottom, 20)
                }
                .scrollIndicators(.hidden)
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
                viewModel.loadNotifications()
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateOnAppear = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .newNotificationReceived)) { _ in
                withAnimation(.easeInOut(duration: 0.3)) {
                    viewModel.loadNotifications()
                }
            }
        }
    }

    // MARK: - UI Sections

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            .padding(.horizontal, 20)
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
            let latestNotifications = Array(viewModel.notifications.prefix(4))
            ForEach(latestNotifications.indices, id: \.self) { idx in
                let notification = latestNotifications[idx]
                Button {
                    // 알림 클릭 시 AlertDetail로 이동
                    coordinator.path.append(HomeCoordinator.HomeRoute.AlertDetail(notification))
                } label: {
                    HomeAlertRow(
                        icon: "shield.lefthalf.fill",
                        title: notification.title,
                        date: notification.receivedDate,
                        isRecent: idx == 0
                    )
                }
                .buttonStyle(.plain)
                .offset(y: animateOnAppear ? 0 : 20)
                .opacity(animateOnAppear ? 1 : 0)
                .animation(.easeInOut(duration: 0.4).delay(Double(idx + 4) * 0.1), value: animateOnAppear)
            }
            if latestNotifications.count < 4 {
                ForEach(latestNotifications.count..<4, id: \.self) { _ in
                    emptyAlertRow()
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
        case .AlertDetail(let notification):
            VideoPlayerView(videoUrl: notification.videoUrl)
        }
    }
}
