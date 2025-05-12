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

    var body: some Scene {
        WindowGroup {
            HomeView(
                viewModel: HomeVM(coordinator: homeCoordinator, calendarVM: calendarVM),
                coordinator: homeCoordinator
            )
        }
    }
}
