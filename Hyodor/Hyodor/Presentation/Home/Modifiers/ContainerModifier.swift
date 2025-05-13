//
//  ContainerModifier.swift
//  Hyodor
//
//  Created by 김상준 on 5/13/25.
//

import SwiftUI

struct ContainerModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .cornerRadius(8)
    }
}

extension View {
    func containerStyle() -> some View {
        modifier(ContainerModifier())
    }
}
