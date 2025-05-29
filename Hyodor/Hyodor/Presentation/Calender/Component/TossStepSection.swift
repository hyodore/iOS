//
//  TossStepSection.swift
//  Hyodor
//
//  Created by 김상준 on 5/30/25.
//

import SwiftUI

struct TossStepSection<Content: View>: View {
    let stepNumber: Int
    let currentStep: Int
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("Step \(stepNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                Spacer()
            }

            content()
        }
    }
}

#Preview {
    TossStepSection(stepNumber: 1, currentStep: 1) {
        Text("Step Content")
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
    .padding()
}
