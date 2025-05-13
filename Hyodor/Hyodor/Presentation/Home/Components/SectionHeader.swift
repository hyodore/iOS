//
//  SectionHeader.swift
//  Hyodor
//
//  Created by 김상준 on 5/13/25.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.bottom, 4)
    }
}
