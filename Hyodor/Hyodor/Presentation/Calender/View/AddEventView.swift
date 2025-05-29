//
//  AddEventView.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import SwiftUI
import AVFoundation

struct AddEventView: View {
    @Bindable var viewModel: HomeVM
    @State var coordinator: CalendarCoordinator
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var eventDate: Date
    @State private var audioRecorder = AudioRecorder()

    @State private var showTitleSection = false
    @State private var showNotesSection = false
    @State private var showAudioSection = false
    @State private var currentStep = 1

    @FocusState private var titleFocused: Bool
    @FocusState private var notesFocused: Bool

    @State private var selectedDate: Date?
    @State private var selectedTime: Date?
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false

    init(viewModel: HomeVM, coordinator: CalendarCoordinator, selectedDate: Date) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.selectedDate = selectedDate
        self._eventDate = State(initialValue: selectedDate)
    }

    var body: some View {
            NavigationView {
                ZStack(alignment: .bottom) {
                    VStack(spacing: 0) {
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 40) {
                                    VStack(spacing: 32) {
                                        TossScheduleHeader(coordinator: coordinator)

                                        if currentStep == 1 {
                                            TossStepSection(stepNumber: 1, currentStep: currentStep) {
                                                TossDateTimeInput(
                                                    selectedDate: $selectedDate,
                                                    selectedTime: $selectedTime,
                                                    showingDatePicker: $showingDatePicker,
                                                    showingTimePicker: $showingTimePicker,
                                                    onCompleted: {
                                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                            showTitleSection = true
                                                            currentStep = 2
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                withAnimation(.easeInOut(duration: 0.5)) {
                                                                    proxy.scrollTo("step2", anchor: .top)
                                                                }
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                                    titleFocused = true
                                                                }
                                                            }
                                                        }
                                                    }
                                                )
                                            }
                                            .id("step1")
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                                removal: .move(edge: .top).combined(with: .opacity)
                                            ))
                                        }

                                        if currentStep == 2 {
                                            TossStepSection(stepNumber: 2, currentStep: currentStep) {
                                                TossTitleInput(
                                                    title: $title,
                                                    titleFocused: $titleFocused,
                                                    onSubmit: {
                                                        if !title.isEmpty {
                                                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                                showNotesSection = true
                                                                currentStep = 3
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                                        proxy.scrollTo("step3", anchor: .top)
                                                                    }
                                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                                                        notesFocused = true
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                )
                                            }
                                            .id("step2")
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                                removal: .move(edge: .top).combined(with: .opacity)
                                            ))
                                        }

                                        if currentStep == 3 {
                                            TossStepSection(stepNumber: 3, currentStep: currentStep) {
                                                TossNotesInput(
                                                    notes: $notes,
                                                    notesFocused: $notesFocused,
                                                    onSkip: {
                                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                                            showAudioSection = true
                                                            currentStep = 4
                                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                                withAnimation(.easeInOut(duration: 0.5)) {
                                                                    proxy.scrollTo("step4", anchor: .top)
                                                                }
                                                            }
                                                        }
                                                    }
                                                )
                                            }
                                            .id("step3")
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                                removal: .move(edge: .top).combined(with: .opacity)
                                            ))
                                        }

                                        if currentStep == 4 {
                                            TossStepSection(stepNumber: 4, currentStep: currentStep) {
                                                TossAudioInput(audioRecorder: audioRecorder)
                                            }
                                            .id("step4")
                                            .transition(.asymmetric(
                                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                                removal: .move(edge: .top).combined(with: .opacity)
                                            ))
                                        }
                                    }
                                    .padding(.top, 20)

                                    Spacer(minLength: 300)
                                }
                                .padding(.horizontal, 20)
                            }
                            .scrollDismissesKeyboard(.interactively)
                        }
                    }

                    TossBottomCTA(
                        title: title,
                        audioRecorder: audioRecorder,
                        currentStep: currentStep,
                        isComplete: !title.isEmpty && selectedDate != nil && selectedTime != nil,
                        onSave: {
                            Task {
                                let finalDate = combineDateAndTime(date: selectedDate, time: selectedTime)
                                let notesText = notes.isEmpty ? nil : notes
                                await viewModel.calendarVM.addEvent(
                                    title: title,
                                    date: finalDate,
                                    notes: notesText,
                                    audioFileURL: audioRecorder.recordingURL
                                )
                                audioRecorder.cleanup()
                                coordinator.dismissAddEvent()
                            }
                        },
                        onSkip: {
                            if currentStep == 3 {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    showAudioSection = true
                                    currentStep = 4
                                }
                            }
                        }
                    )
                }
                .background(Color(.systemBackground))
                .navigationTitle("")
                .navigationBarHidden(true)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .onAppear {
                    Task {
                        await audioRecorder.requestPermission()
                    }
                }
                .alert("마이크 권한이 필요해요", isPresented: $audioRecorder.showingPermissionAlert) {
                    Button("설정으로 이동") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    }
                    Button("나중에", role: .cancel) {}
                } message: {
                    Text("음성 메모를 녹음하려면\n마이크 접근 권한을 허용해주세요")
                }
            }
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

struct TossStepSection<Content: View>: View {
    let stepNumber: Int
    let currentStep: Int
    let content: Content

    init(stepNumber: Int, currentStep: Int, @ViewBuilder content: () -> Content) {
        self.stepNumber = stepNumber
        self.currentStep = currentStep
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Circle()
                    .fill(stepNumber <= currentStep ? Color.blue : Color(.systemGray4))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Text("\(stepNumber)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                    .scaleEffect(stepNumber == currentStep ? 1.2 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: currentStep)

                Text("Step \(stepNumber)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(stepNumber <= currentStep ? .blue : .secondary)

                Spacer()
            }

            content
        }
        .opacity(stepNumber <= currentStep ? 1.0 : 0.6)
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}

struct TossScheduleHeader: View {
    let coordinator: CalendarCoordinator

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    coordinator.dismissAddEvent()
                }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }
                Spacer()
            }
        }
    }
}

struct TossDateTimeInput: View {
    @Binding var selectedDate: Date?
    @Binding var selectedTime: Date?
    @Binding var showingDatePicker: Bool
    @Binding var showingTimePicker: Bool
    let onCompleted: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("언제 일정이 있나요?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("날짜와 시간을 모두 선택해주세요")
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 12) {
                Button(action: {
                    showingDatePicker = true
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(selectedDate != nil ? .blue : .gray)

                        if let date = selectedDate {
                            Text(date.toKoreanDateString())
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        } else {
                            Text("날짜 선택")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        if selectedDate != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedDate != nil ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    )
                }

                Button(action: {
                    showingTimePicker = true
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(selectedTime != nil ? .blue : .gray)

                        if let time = selectedTime {
                            Text(time.toKoreanTimeString())
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        } else {
                            Text("시간 선택")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        if selectedTime != nil {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedTime != nil ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    )
                }
            }
        }
        .sheet(isPresented: $showingDatePicker) {
            TossDatePickerSheet(selectedDate: $selectedDate) {
                checkCompletion()
            }
        }
        .sheet(isPresented: $showingTimePicker) {
            TossTimePickerSheet(selectedTime: $selectedTime) {
                checkCompletion()
            }
        }
    }

    private func checkCompletion() {
        if selectedDate != nil && selectedTime != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onCompleted()
            }
        }
    }
}



struct TossTitleInput: View {
    @Binding var title: String
    @FocusState.Binding var titleFocused: Bool
    let onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("어떤 일정인가요?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            TextField("", text: $title)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.vertical, 20)
                .padding(.horizontal, 0)
                .focused($titleFocused)
                .submitLabel(.next)
                .background(
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(titleFocused ? Color.blue : Color(.systemGray4))
                            .animation(.easeInOut(duration: 0.2), value: titleFocused)
                    }
                )
                .overlay(
                    HStack {
                        if title.isEmpty {
                            Text("일정 제목을 입력해주세요")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .opacity(titleFocused ? 0.7 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: titleFocused)
                        }
                        Spacer()
                    }
                )
                .onSubmit {
                    if !title.isEmpty {
                        onSubmit()
                    }
                }
        }
    }
}

struct TossDatePickerSheet: View {
    @Binding var selectedDate: Date?
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate = Date()
    let onDateSelected: () -> Void

    var body: some View {
        NavigationView {
            VStack {

                DatePicker("", selection: $tempDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        selectedDate = tempDate
                        onDateSelected()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempDate = selectedDate ?? Date()
        }
    }
}

struct TossTimePickerSheet: View {
    @Binding var selectedTime: Date?
    @Environment(\.dismiss) private var dismiss
    @State private var tempTime = Date()
    let onTimeSelected: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $tempTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        selectedTime = tempTime
                        onTimeSelected()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempTime = selectedTime ?? Date()
        }
    }
}

struct TossNotesInput: View {
    @Binding var notes: String
    @FocusState.Binding var notesFocused: Bool
    let onSkip: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("추가로 메모할 내용이 있나요?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("선택사항이에요. 건너뛰셔도 됩니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextField("", text: $notes)
                .font(.body)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .focused($notesFocused)
                .submitLabel(.next)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(notesFocused ? Color.blue : Color.clear, lineWidth: 2)
                                .animation(.easeInOut(duration: 0.2), value: notesFocused)
                        )
                )
                .overlay(
                    HStack {
                        if notes.isEmpty && !notesFocused {
                            Text("메모를 입력해주세요")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.leading, 20)
                        }
                        Spacer()
                    }
                )
                .onSubmit {
                    onSkip()
                }
        }
    }
}

struct TossAudioInput: View {
    let audioRecorder: AudioRecorder

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("음성 메모를 추가하시겠어요?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("목소리로 더 자세한 내용을 남겨보세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if audioRecorder.isRecording {
                TossRecordingCard(audioRecorder: audioRecorder)
            } else if audioRecorder.recordingURL != nil {
                TossAudioPlaybackCard(audioRecorder: audioRecorder)
            } else {
                Button(action: {
                    Task {
                        await audioRecorder.startRecording()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.title2)
                            .foregroundColor(.blue)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("음성 메모 녹음하기")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)

                            Text("탭해서 녹음을 시작하세요")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .disabled(!audioRecorder.hasPermission)
                .opacity(audioRecorder.hasPermission ? 1.0 : 0.6)
            }
        }
    }
}

struct TossRecordingCard: View {
    let audioRecorder: AudioRecorder

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .scaleEffect(audioRecorder.isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(), value: audioRecorder.isRecording)

                Circle()
                    .fill(Color.red)
                    .frame(width: 16, height: 16)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("녹음 중")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(audioRecorder.recordingTime)
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .fontWeight(.medium)
            }

            Spacer()

            Button(action: {
                audioRecorder.stopRecording()
            }) {
                Text("중지")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct TossAudioPlaybackCard: View {
    let audioRecorder: AudioRecorder

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: "waveform.circle.fill")
                    .font(.title)
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text("음성 메모 완료")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("재생해서 확인해보세요")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: {
                    audioRecorder.deleteRecording()
                }) {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }

            HStack(spacing: 12) {
                if !audioRecorder.isPlaying {
                    Button(action: {
                        Task {
                            await audioRecorder.playRecording()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                                .font(.callout)
                            Text("재생")
                                .font(.callout)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(Capsule())
                    }
                } else {
                    Button(action: {
                        audioRecorder.stopPlayback()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "stop.fill")
                                .font(.callout)
                            Text("중지")
                                .font(.callout)
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.gray)
                        .clipShape(Capsule())
                    }

                    Text(audioRecorder.playbackTime)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())
                }

                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct TossBottomCTA: View {
    let title: String
    let audioRecorder: AudioRecorder
    let currentStep: Int
    let isComplete: Bool
    let onSave: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)

            HStack(spacing: 12) {
                Button(action: {
                    if currentStep == 3 {
                        onSkip()
                    } else {
                        onSave()
                    }
                }) {
                    HStack {
                        if currentStep == 3 {
                            Text("넘어가기")
                                .font(.headline)
                                .fontWeight(.semibold)
                        } else if isComplete {
                            Text("일정 저장하기")
                                .font(.headline)
                                .fontWeight(.semibold)
                        } else {
                            Text("날짜/시간과 제목을 입력해주세요")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill((isComplete || currentStep == 3) ? Color.blue : Color(.systemGray3))
                    )
                }
                .disabled(!isComplete && currentStep != 3)
                .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    AddEventView(
        viewModel: HomeVM(coordinator: HomeCoordinator()),
        coordinator: CalendarCoordinator(),
        selectedDate: Date()
    )
}
