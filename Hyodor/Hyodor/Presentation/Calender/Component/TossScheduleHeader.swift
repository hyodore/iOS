//
//  TossScheduleHeader.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct TossScheduleHeader: View {
    let viewModel: AddEventViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: {
                    viewModel.dismiss()
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
