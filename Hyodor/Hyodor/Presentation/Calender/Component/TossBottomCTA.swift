//
//  TossBottomCTA.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct TossBottomCTA: View {
    @Bindable var viewModel: AddEventViewModel

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)

            HStack(spacing: 12) {
                Button(action: {
                    if viewModel.currentStep == 3 {
                        viewModel.skipToStep4()
                    } else {
                        viewModel.saveEvent()
                    }
                }) {
                    HStack {
                        if viewModel.currentStep == 3 {
                            Text("넘어가기")
                                .font(.headline)
                                .fontWeight(.semibold)
                        } else if viewModel.isComplete {
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
                            .fill((viewModel.isComplete || viewModel.currentStep == 3) ? Color.blue : Color(.systemGray3))
                    )
                }
                .disabled(!viewModel.isComplete && viewModel.currentStep != 3)
                .animation(.easeInOut(duration: 0.2), value: viewModel.currentStep)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(Color(.systemBackground))
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
