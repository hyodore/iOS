//
//  TossDateTimeInput.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct TossDateTimeInput: View {
    @Bindable var viewModel: AddEventViewModel

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
                    viewModel.showingDatePicker = true
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(viewModel.selectedDate != nil ? .blue : .gray)

                        if let date = viewModel.selectedDate {
                            Text(date.toKoreanDateString())
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        } else {
                            Text("날짜 선택")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        if viewModel.selectedDate != nil {
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
                                    .stroke(viewModel.selectedDate != nil ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    )
                }

                Button(action: {
                    viewModel.showingTimePicker = true
                }) {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(viewModel.selectedTime != nil ? .blue : .gray)

                        if let time = viewModel.selectedTime {
                            Text(time.toKoreanTimeString())
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        } else {
                            Text("시간 선택")
                                .foregroundColor(.gray)
                        }

                        Spacer()

                        if viewModel.selectedTime != nil {
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
                                    .stroke(viewModel.selectedTime != nil ? Color.blue : Color.clear, lineWidth: 2)
                            )
                    )
                }
            }
        }
        .sheet(isPresented: $viewModel.showingDatePicker) {
            TossDatePickerSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showingTimePicker) {
            TossTimePickerSheet(viewModel: viewModel)
        }
    }
}
