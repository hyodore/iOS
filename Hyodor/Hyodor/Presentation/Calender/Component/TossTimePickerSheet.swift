//
//  TossTimePickerSheet.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct TossTimePickerSheet: View {
    @Bindable var viewModel: AddEventViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var tempTime = Date()

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
                        viewModel.updateSelectedTime(tempTime)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .onAppear {
            tempTime = viewModel.selectedTime ?? Date()
        }
    }
}
