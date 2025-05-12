//
//  CalenderView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

struct CalendarView: View {
    @Bindable var viewModel: HomeVM
    @State private var coordinator = CalendarCoordinator()
    @State private var selectedSchedule: Schedule? = nil // 추가: 선택된 일정 상태

    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                Button(action: {
                    viewModel.selectedDate = Date()}) {
                    Text("오늘")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.blue, lineWidth: 1)
                        )
                }
                Button(action: {
                    coordinator.presentAddEvent()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            HStack {
                Button(action: { moveMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text(monthYearString(from: viewModel.selectedDate))
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button(action: { moveMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)

            // 요일 헤더
            HStack {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }

            // 캘린더 그리드
            let days = daysInMonth()
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(Array(0..<days.count), id: \.self) { index in
                    let date = days[index]
                    if let date = date {
                        CalendarCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasEvents: viewModel.calendarVM.events.contains { calendar.isDate($0.date, inSameDayAs: date) }
                        )
                        .onTapGesture {
                            viewModel.selectedDate = date
                        }
                    } else {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 40)
                    }
                }
            }


            // 선택된 날짜
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fullDateString(from: viewModel.selectedDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            // 일정 목록
            List {
                ForEach(viewModel.calendarVM.events.filter {
                    calendar.isDate($0.date, inSameDayAs: viewModel.selectedDate)
                }) { event in
                    Button {
                        // 일정 탭 시 상세 뷰 표시
                        selectedSchedule = event
                    } label: {
                        ScheduleRow(schedule: event) {
                            Task {
                                await viewModel.calendarVM.removeEvent(event)
                            }
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .listStyle(PlainListStyle())
            Spacer()
        }
        .padding()
        .sheet(item: $selectedSchedule) { schedule in
            // 선택된 일정 상세 뷰 표시
            NavigationStack {
                ScheduleDetailView(schedule: schedule)
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
        .sheet(isPresented: $coordinator.showAddEvent) {
            AddEventView(
                viewModel: viewModel,
                coordinator: coordinator,
                selectedDate: viewModel.selectedDate)
        }
    }

    // MARK: - 캘린더 유틸
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

    private func monthYearString(from date: Date) -> String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }

    private func fullDateString(from date: Date) -> String {
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
        return dateFormatter.string(from: date)
    }
}
