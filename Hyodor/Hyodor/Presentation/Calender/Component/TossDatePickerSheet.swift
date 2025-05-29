//
//  TossDatePickerSheet.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct TossDatePickerSheet: View {
    @Bindable var viewModel: AddEventViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempDate = Date()

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
                        viewModel.updateSelectedDate(tempDate)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempDate = viewModel.selectedDate ?? Date()
        }
    }
}
