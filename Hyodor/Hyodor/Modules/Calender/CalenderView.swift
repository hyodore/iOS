//
//  CalenderView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI
import PhotosUI

// 일정 데이터 모델
struct Event: Identifiable, Equatable, Hashable {
    var id = UUID()
    var title: String
    var date: Date
    var color: Color = .blue
    var notes: String = ""

    static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
// 일정 관리 클래스
class EventStore: ObservableObject {
    @Published var events: [Event] = []

    func addEvent(_ event: Event) {
        events.append(event)
    }

    func removeEvent(_ event: Event) {
        events.removeAll { $0.id == event.id }
    }

    func eventsForDate(_ date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter {
            calendar.isDate($0.date, inSameDayAs: date)
        }
    }

    func hasEvents(for date: Date) -> Bool {
        !eventsForDate(date).isEmpty
    }
}
// 일별 셀 뷰
struct DayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 2) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(foregroundColor)
                .frame(width: 36, height: 36)
                .background(
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(Color.blue)
                        } else if isToday {
                            Circle()
                                .strokeBorder(Color.blue, lineWidth: 1)
                        }
                    }
                )

            // 일정이 있으면 점으로 표시
            if hasEvents {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 40)
    }

    private var foregroundColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .blue
        } else {
            return .primary
        }
    }
}
// 일정 추가 화면
struct AddEventView: View {
    @Binding var isPresented: Bool
    @ObservedObject var eventStore: EventStore
    var selectedDate: Date

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var eventDate: Date
    @State private var eventColor: Color = .blue

    init(isPresented: Binding<Bool>, eventStore: EventStore, selectedDate: Date) {
        self._isPresented = isPresented
        self.eventStore = eventStore
        self.selectedDate = selectedDate

        // 선택된 날짜의 오후 12시로 초기화
        var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
        components.hour = 12
        self._eventDate = State(initialValue: Calendar.current.date(from: components) ?? selectedDate)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("일정 정보")) {
                    TextField("제목", text: $title)
                    DatePicker("날짜 및 시간", selection: $eventDate)

                    HStack {
                        Text("색상")
                        Spacer()
                        ColorPicker("", selection: $eventColor)
                    }
                }

                Section(header: Text("메모")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                Section {
                    Button("저장하기") {
                        let newEvent = Event(
                            title: title,
                            date: eventDate,
                            color: eventColor,
                            notes: notes
                        )
                        eventStore.addEvent(newEvent)
                        isPresented = false
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("새 일정")
            .navigationBarItems(
                leading: Button("취소") {
                    isPresented = false
                }
            )
        }
    }
}

struct EventListView: View {
    let events: [Event]
    let dateString: String
    @ObservedObject var eventStore: EventStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(dateString)
                .font(.headline)
                .padding(.horizontal)

            if events.isEmpty {
                HStack {
                    Spacer()
                    Text("일정이 없습니다")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
            } else {
                // List 대신 ScrollView와 LazyVStack 사용
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(events) { event in
                            EventRow(event: event, eventStore: eventStore)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
}
struct EventRow: View {
    let event: Event
    @ObservedObject var eventStore: EventStore

    // 변수를 View 빌더 외부로 이동
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        HStack {
            Rectangle()
                .fill(event.color)
                .frame(width: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)

                // 계산 속성 사용
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

            // 삭제 버튼 추가
            Button(action: {
                eventStore.removeEvent(event)
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
// 메인 캘린더 뷰
struct CalendarView: View {
    @StateObject private var eventStore = EventStore()
    @State private var selectedDate = Date()
    @State private var displayedMonth: Date = Date()
    @State private var showingAddEvent = false

    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols

    var body: some View {
        VStack(spacing: 20) {
            // 헤더 부분

            HStack {
                Spacer()
                Button(action: {
                    selectedDate = Date()
                    displayedMonth = Date()
                }) {
                    Text("오늘")
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.blue, lineWidth: 1)
                        )
                }

                // 일정 추가 버튼
                Button(action: {
                    showingAddEvent = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }

            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }

                Spacer()

                VStack {
                    Text(monthYearString(from: displayedMonth))
                        .font(.title2)
                        .fontWeight(.bold)
                }

                Spacer()

                Button(action: nextMonth) {
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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        DayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasEvents: eventStore.hasEvents(for: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        // 빈 셀
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 40)
                    }
                }
            }

            // 선택된 날짜와 일정 관리 버튼
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(fullDateString(from: selectedDate))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.horizontal)

            // 선택된 날짜의 일정 목록
            EventListView(
                events: eventStore.eventsForDate(selectedDate),
                dateString: "일정",
                eventStore: eventStore
            )
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(
                isPresented: $showingAddEvent,
                eventStore: eventStore,
                selectedDate: selectedDate
            )
        }
    }

    // 기존 함수들은 동일하게 유지...
    private func daysInMonth() -> [Date?] {
        var days = [Date?]()

        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let lastDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstDayOfMonth)!

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

    private func monthYearString(from date: Date) -> String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: date)
    }

    private func fullDateString(from date: Date) -> String {
        dateFormatter.dateFormat = "yyyy년 M월 d일 EEEE"
        return dateFormatter.string(from: date)
    }

    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }

    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) {
            displayedMonth = newMonth
        }
    }
}

