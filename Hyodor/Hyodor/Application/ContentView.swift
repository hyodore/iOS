//
//  ContentView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

@main
struct HyodorApp: App {
    let calendarVM = CalendarVM()
    let homeCoordinator = HomeCoordinator()

    @State private var isActive = false

    var body: some Scene {
        WindowGroup {
            if isActive {
                HomeView(
                    viewModel: HomeVM(coordinator: homeCoordinator, calendarVM: calendarVM),
                    coordinator: homeCoordinator
                )
            } else {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
            }

        }
    }
}
