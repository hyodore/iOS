//
//  AddEventView.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import SwiftUI

// MARK: - 일정 추가 뷰
struct AddEventView: View {
    @State var viewModel: CalendarViewModel
    @State var coordinator: CalendarCoordinator
    var selectedDate: Date

    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var eventDate: Date
    @State private var eventColor: Color = .blue

    init(viewModel: CalendarViewModel, coordinator: CalendarCoordinator, selectedDate: Date) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.selectedDate = selectedDate
        self._eventDate = State(initialValue: selectedDate)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("일정 정보")) {
                    TextField("제목", text: $title)
                    DatePicker("날짜 및 시간", selection: $eventDate)
                }
                Section(header: Text("메모")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                Section {
                    Button("저장하기") {
                        viewModel.addEvent(title: title, date: eventDate, notes: notes)
                        coordinator.dismissAddEvent()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .navigationTitle("새 일정")
            .navigationBarItems(
                leading: Button("취소") {
                    coordinator.dismissAddEvent()
                }
            )
        }
    }
}

