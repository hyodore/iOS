//
//  CalendarView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

struct CalendarView: View {
    @Bindable var viewModel: HomeVM
    @State private var coordinator = CalendarCoordinator()
    @State private var selectedSchedule: Schedule? = nil
    @State private var showingDatePicker = false

    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

    var body: some View {
        ZStack{
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                CalendarHeader(
                    selectedDate: viewModel.selectedDate,
                    onDatePickerTap: {
                        showingDatePicker = true
                    },
                    onMonthChanged: { offset in
                        moveMonth(offset)
                    }
                )
                CalendarGrid(
                    selectedDate: viewModel.selectedDate,
                    events: viewModel.calendarVM.events,
                    weekdaySymbols: weekdaySymbols,
                    onDateSelected: { date in
                        viewModel.selectedDate = date
                    },
                    daysInMonth: daysInMonth()
                )
                ScheduleList(
                    selectedDate: viewModel.selectedDate,
                    events: viewModel.calendarVM.events,
                    onScheduleTap: { schedule in
                        selectedSchedule = schedule
                    }
                )
            }
            .sheet(item: $selectedSchedule) { schedule in
                ScheduleDetailView(
                    schedule: schedule,
                    onDelete: {
                        Task {
                            await viewModel.calendarVM.removeEvent(schedule)
                            selectedSchedule = nil
                        }
                    }
                )
            }
            .sheet(isPresented: $coordinator.showAddEvent) {
                // 🔥 수정된 부분: MVVM 패턴에 맞게 AddEventView 생성
                AddEventView.create(
                    homeViewModel: viewModel,
                    coordinator: coordinator,
                    selectedDate: viewModel.selectedDate
                )
            }
            .sheet(isPresented: $showingDatePicker) {
                DatePickerView(selectedDate: $viewModel.selectedDate)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                CustomBarItems(
                    onTodayTap: {
                        viewModel.selectedDate = Date()
                    },
                    onAddTap: {
                        coordinator.presentAddEvent()
                    }
                )
            }
        }
    }

    private func daysInMonth() -> [Date?] {
        var days = [Date?]()

        let comps = calendar.dateComponents([.year, .month], from: viewModel.selectedDate)
        guard let firstDayOfMonth = calendar.date(from: comps) else { return [] }
        guard let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        let daysInMonth = calendar.component(.day, from: lastDayOfMonth)
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        let remainingCells = 42 - days.count
        if remainingCells > 0 && remainingCells < 7 {
            for _ in 0..<remainingCells {
                days.append(nil)
            }
        }

        return days
    }

    private func moveMonth(_ offset: Int) {
        if let newDate = calendar.date(byAdding: .month, value: offset, to: viewModel.selectedDate) {
            viewModel.selectedDate = newDate
        }
    }
}

struct CustomBarItems: View {
    let onTodayTap: () -> Void
    let onAddTap: () -> Void

    var body: some View {
        HStack{
            Button(action: onTodayTap) {
                Text("오늘")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.blue, lineWidth: 1)
                    )
            }

            Button(action: onAddTap) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                    )
            }
        }
    }
}

struct CalendarHeader: View {
    let selectedDate: Date
    let onDatePickerTap: () -> Void
    let onMonthChanged: (Int) -> Void

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { onMonthChanged(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }

                Spacer()

                Button(action: onDatePickerTap) {
                    HStack(spacing: 8) {
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button(action: { onMonthChanged(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .padding(.top,20)
    }
}

struct CalendarGrid: View {
    let selectedDate: Date
    let events: [Schedule]
    let weekdaySymbols: [String]
    let onDateSelected: (Date) -> Void
    let daysInMonth: [Date?]

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { index, symbol in
                    Text(symbol)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(index == 0 ? .red : (index == 6 ? .blue : .secondary))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 8) {
                ForEach(Array(0..<daysInMonth.count), id: \.self) { index in
                    let date = daysInMonth[index]
                    if let date = date {
                        CalendarCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasEvents: events.contains { calendar.isDate($0.date, inSameDayAs: date) },
                            eventCount: events.filter { calendar.isDate($0.date, inSameDayAs: date) }.count
                        )
                        .onTapGesture {
                            onDateSelected(date)
                        }
                    } else {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 24)
        .background(Color(.systemBackground))
    }
}

struct CalendarCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let eventCount: Int

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()

    var body: some View {
        VStack(spacing: 4) {
            Text(dayFormatter.string(from: date))
                .font(.system(size: 16, weight: isSelected ? .bold : .medium))
                .foregroundColor(textColor)

            if hasEvents {
                HStack(spacing: 2) {
                    ForEach(0..<min(eventCount, 3), id: \.self) { _ in
                        Circle()
                            .fill(isSelected ? Color.white : Color.blue)
                            .frame(width: 4, height: 4)
                    }
                    if eventCount > 3 {
                        Text("+")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(isSelected ? .white : .blue)
                    }
                }
            } else {
                Spacer()
                    .frame(height: 8)
            }
        }
        .frame(width: 44, height: 44)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        )
    }

    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue.opacity(0.1)
        } else {
            return .clear
        }
    }
}

struct ScheduleList: View {
    let selectedDate: Date
    let events: [Schedule]
    let onScheduleTap: (Schedule) -> Void

    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        return formatter
    }()

    var todayEvents: [Schedule] {
        events.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        VStack(spacing: 0) {
            if !todayEvents.isEmpty {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(todayEvents.sorted { $0.date < $1.date }) { event in
                            ScheduleCard(
                                schedule: event,
                                onTap: {
                                    onScheduleTap(event)
                                }
                            )
                        }
                    }
                }
            } else {
                EmptyScheduleView()
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.white))
    }
}

struct ScheduleCard: View {
    let schedule: Schedule
    let onTap: () -> Void

    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                Text(timeFormatter.string(from: schedule.date))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.blue)

                Text(schedule.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(CardButtonStyle())
    }
}

struct EmptyScheduleView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                Text("등록된 일정이 없습니다")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)

                Text("새로운 일정을 추가해보세요")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate: Date

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._tempDate = State(initialValue: selectedDate.wrappedValue)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                DatePicker("", selection: $tempDate, displayedComponents: .date)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("날짜 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        selectedDate = tempDate
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

#Preview {
    CalendarView(viewModel: HomeVM(coordinator: HomeCoordinator()))
}
