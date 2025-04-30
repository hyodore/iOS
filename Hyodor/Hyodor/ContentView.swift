//
//  ContentView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

@main
struct ContentView: App {
    let coordinator = HomeCoordinator()
    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel(coordinator: coordinator), coordinator: coordinator)
        }
    }
}
