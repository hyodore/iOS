//
//  CalenderView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

struct CalendarView: View {
    @State private var viewModel = CalendarViewModel()
    @State private var coordinator = CalendarCoordinator()

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
                ForEach(days.indices, id: \.self) { index in
                    let date = days[index]
                    if let date = date {
                        CalendarCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasEvents: viewModel.events.contains { calendar.isDate($0.date, inSameDayAs: date) }
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
                ForEach(viewModel.events.filter {
                    calendar.isDate($0.date, inSameDayAs: viewModel.selectedDate)
                }) { event in
                    EventRow(event: event, viewModel: viewModel)
                }
            }
            .listStyle(PlainListStyle())
            Spacer()
        }
        .padding()
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

// MARK: - 일정 행
struct EventRow: View {
    let event: Event
    @State var viewModel: CalendarViewModel

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        HStack {
            Rectangle()
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(timeFormatter.string(from: event.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !event.notes.isEmpty {
                    Text(event.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 4)

            Spacer()

            Button(action: {
                viewModel.removeEvent(event)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}

#Preview {
    CalendarView()
}
