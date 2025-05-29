//
//  TossTitleInput.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct ASTitleInput: View {
    @Bindable var viewModel: AddScheduleViewModel

    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("어떤 일정인가요?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            TextField("", text: $viewModel.title)
                .font(.title3)
                .fontWeight(.medium)
                .padding(.vertical, 20)
                .padding(.horizontal, 0)
                .focused($isTextFieldFocused)
                .submitLabel(.next) 
                .background(
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: 3)
                            .foregroundColor(isTextFieldFocused ? Color.blue : Color(.systemGray4))
                            .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                    }
                )
                .overlay(
                    HStack {
                        if viewModel.title.isEmpty {
                            Text("일정 제목을 입력해주세요")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                                .opacity(isTextFieldFocused ? 0.7 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
                        }
                        Spacer()
                    }
                )
                .onSubmit {
                    if viewModel.canProceedFromStep2 {
                        viewModel.moveToStep3()
                    }
                }
                .onChange(of: viewModel.titleFocused) { _, newValue in
                    isTextFieldFocused = newValue
                }
                .onChange(of: isTextFieldFocused) { _, newValue in
                    viewModel.titleFocused = newValue
                }
        }
        .onAppear {
            if viewModel.titleFocused {
                isTextFieldFocused = true
            }
        }
    }
}


#Preview {
    ASTitleInput(viewModel: AddScheduleViewModel(
        homeViewModel: HomeVM(coordinator: HomeCoordinator()),
        coordinator: CalendarCoordinator(),
        selectedDate: Date()
    ))
    .padding()
}
