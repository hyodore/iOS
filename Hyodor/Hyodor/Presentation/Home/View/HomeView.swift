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
            .sheet(item: $viewModel.selectedSchedule) { schedule in
                scheduleDetailSheet(for: schedule)
            }
            .navigationDestination(for: HomeCoordinator.HomeRoute.self) { route in
                destinationView(for: route)
            }
            .onAppear {
                viewModel.getLatestNotifications()
                withAnimation(.easeInOut(duration: 0.5)) {
                    animateOnAppear = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .newNotificationReceived)) { _ in
                viewModel.getLatestNotifications()
            }
        }
    }

    // Header UI
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Button {
                    viewModel.didTapCalendar()
                } label: {
                    HomeMenuButton(imageName: "calendar", title: "캘린더")
                        .scaleEffect(animateOnAppear ? 1.0 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateOnAppear)
                }
                Button {
                    viewModel.didTapSharedAlbum()
                } label: {
                    HomeMenuButton(imageName: "camera", title: "공유 앨범")
                        .scaleEffect(animateOnAppear ? 1.0 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: animateOnAppear)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // Content UI
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            scheduleSection
            alertSection
        }
        .padding(.horizontal, 20)
    }

    // Scheduler UI
    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "부모님 일정")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            ForEach(0..<4) { idx in
                if idx < viewModel.displayedEvents.count {
                    HomeScheduleRowBtn(index: idx)
                        .offset(y: animateOnAppear ? 0 : 20)
                        .opacity(animateOnAppear ? 1 : 0)
                        .animation(.easeInOut(duration: 0.4).delay(Double(idx) * 0.1), value: animateOnAppear)
                } else {
                    emptyScheduleRow()
                }
            }
        }

    }

    private func HomeScheduleRowBtn(index: Int) -> some View {
        let event = viewModel.displayedEvents[index]
        let isToday = viewModel.isToday(for: event)

        return Button {
            viewModel.didSelectSchedule(event)
        } label: {
            HomeScheduleRow(
                title: event.title,
                date: event.date,
                isToday: isToday
            )
        }
        .buttonStyle(.plain)
    }

    private func emptyScheduleRow() -> some View {
        HomeScheduleRow(
            title: "",
            date: Date(),
            isToday: false
        )
        .opacity(0)
    }

    private func scheduleDetailSheet(for schedule: Schedule) -> some View {
        NavigationStack {
            ScheduleDetailView(
                schedule: schedule,
                onDelete: {
                    Task {
                        await viewModel.deleteSchedule(schedule)
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        viewModel.dismissScheduleDetail()
                    }
                }
            }
            .navigationTitle("일정 상세")
        }
    }

    // Alert UI

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

            ForEach(0..<4) { idx in
                if idx < viewModel.notifications.count {
                   HomeAlertRowBtn(idx: idx)
                        .offset(y: animateOnAppear ? 0 : 20)
                        .opacity(animateOnAppear ? 1 : 0)
                        .animation(.easeInOut(duration: 0.4).delay(Double(idx) * 0.1), value: animateOnAppear)
                } else {

                    emptyAlertRow()
                }
            }
        }
    }

    private func HomeAlertRowBtn(idx: Int) -> some View {
        let notification = viewModel.notifications[idx]

        return Button {
            viewModel.didSelectNotification(notification)
        } label: {
            HomeAlertRow(
                icon: "shield.lefthalf.fill",
                title: notification.title,
                date: notification.receivedDate,
                isRecent: idx == 0
            )
        }
        .buttonStyle(.plain)
    }

    private func emptyAlertRow() -> some View {
        HomeAlertRow(
            icon: "shield.lefthalf.fill",
            title: "",
            date: Date()
        )
        .opacity(0)
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
