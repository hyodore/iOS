//
//  AddEventView.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import SwiftUI

struct AddEventView: View {
    @Bindable var viewModel: HomeVM
    @State var coordinator: CalendarCoordinator
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var eventDate: Date
    var selectedDate: Date

    init(viewModel: HomeVM, coordinator: CalendarCoordinator, selectedDate: Date) {
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
                        viewModel.calendarVM.addEvent(title: title, date: eventDate, notes: notes)
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


