//
//  AddEventViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI
import AVFoundation

@Observable
class AddScheduleViewModel {
    private let homeViewModel: HomeVM
    private let coordinator: CalendarCoordinator

    var title: String = ""
    var notes: String = ""
    var selectedDate: Date?
    var selectedTime: Date?
    var currentStep: Int = 1
    var audioRecorder = AudioRecorder()

    var showTitleSection = false
    var showNotesSection = false
    var showAudioSection = false
    var showingDatePicker = false
    var showingTimePicker = false
    var titleFocused = false
    var notesFocused = false

    var isComplete: Bool {
        !title.isEmpty && selectedDate != nil && selectedTime != nil
    }

    var canProceedFromStep1: Bool {
        selectedDate != nil && selectedTime != nil
    }

    var canProceedFromStep2: Bool {
        !title.isEmpty
    }

    init(homeViewModel: HomeVM, coordinator: CalendarCoordinator, selectedDate: Date) {
        self.homeViewModel = homeViewModel
        self.coordinator = coordinator
        self.selectedDate = selectedDate
    }

    func moveToStep2() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showTitleSection = true
            currentStep = 2
        }
    }

    func moveToStep3() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showNotesSection = true
            currentStep = 3
        }
    }

    func moveToStep4() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            showAudioSection = true
            currentStep = 4
        }
    }

    func skipToStep4() {
        if currentStep == 3 {
            moveToStep4()
        }
    }

    func checkDateTimeCompletion() {
        if canProceedFromStep1 && currentStep == 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.moveToStep2()
            }
        }
    }

    func checkTitleCompletion() {
        if canProceedFromStep2 && currentStep == 2 {
            moveToStep3()
        }
    }

    func updateSelectedDate(_ date: Date) {
        selectedDate = date
        checkDateTimeCompletion()
    }

    func updateSelectedTime(_ time: Date) {
        selectedTime = time
        checkDateTimeCompletion()
    }

    func updateTitle(_ newTitle: String) {
        title = newTitle
    }

    func updateNotes(_ newNotes: String) {
        notes = newNotes
    }

    func setTitleFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.titleFocused = true
        }
    }

    func setNotesFocus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.notesFocused = true
        }
    }

    func requestAudioPermission() async {
        await audioRecorder.requestPermission()
    }

    func saveEvent() {
        Task {
            let finalDate = combineDateAndTime(date: selectedDate, time: selectedTime)
            let notesText = notes.isEmpty ? nil : notes

            await homeViewModel.calendarVM.addEvent(
                title: title,
                date: finalDate,
                notes: notesText,
                audioFileURL: audioRecorder.recordingURL
            )

            audioRecorder.cleanup()
            coordinator.dismissAddEvent()
        }
    }

    func dismiss() {
        audioRecorder.cleanup()
        coordinator.dismissAddEvent()
    }

    private func combineDateAndTime(date: Date?, time: Date?) -> Date {
        guard let selectedDate = date, let selectedTime = time else {
            return Date()
        }

        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        return calendar.date(from: combinedComponents) ?? Date()
    }
}
