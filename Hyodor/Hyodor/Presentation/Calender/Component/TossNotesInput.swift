//
//  TossNotesInput.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct TossNotesInput: View {
    @Bindable var viewModel: AddEventViewModel

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("추가로 메모할 내용이 있나요?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("선택사항이에요. 건너뛰셔도 됩니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextField("", text: $viewModel.notes)
                .font(.body)
                .padding(.vertical, 20)
                .padding(.horizontal, 16)
                .focused($isTextFieldFocused)
                .submitLabel(.next) // "다음" 버튼으로 표시
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemGray6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isTextFieldFocused ? Color.blue : Color.clear, lineWidth: 2)
                                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                        )
                )
                .overlay(
                    HStack {
                        if viewModel.notes.isEmpty && !isTextFieldFocused {
                            Text("메모를 입력해주세요")
                                .font(.body)
                                .foregroundColor(.gray)
                                .padding(.leading, 20)
                        }
                        Spacer()
                    }
                )
                .onSubmit {
                    // 🔥 리턴 키를 누르면 다음 단계로 진행
                    viewModel.moveToStep4()
                }
                .onChange(of: viewModel.notesFocused) { _, newValue in
                    isTextFieldFocused = newValue
                }
                .onChange(of: isTextFieldFocused) { _, newValue in
                    viewModel.notesFocused = newValue
                }
        }
        .onAppear {
            if viewModel.notesFocused {
                isTextFieldFocused = true
            }
        }
    }
}



#Preview {
    TossNotesInput(viewModel: AddEventViewModel(
        homeViewModel: HomeVM(coordinator: HomeCoordinator()),
        coordinator: CalendarCoordinator(),
        selectedDate: Date()
    ))
    .padding()
}
