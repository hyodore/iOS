//
//  SplashView.swift
//  Hyodor
//
//  Created by 김상준 on 5/12/25.
//

import SwiftUI

struct SplashView: View {
    @State private var size = 0.8
    @State private var opacity = 0.5

    var body: some View {
        VStack {
            Text("HYODOR")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.blue)
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.2)) {
                        self.size = 1.0
                        self.opacity = 1.0
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.976, green: 0.976, blue: 0.976))
        .ignoresSafeArea()

    }
}

