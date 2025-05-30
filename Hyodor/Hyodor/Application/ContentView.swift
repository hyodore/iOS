//
//  ContentView.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

@main
struct HyodorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let homeCoordinator = HomeCoordinator()
    let sharedAlbumViewModel = SharedAlbumVM()

    @State private var isActive = false

    var body: some Scene {
        WindowGroup {
            if isActive {
                HomeView(
                    viewModel: HomeVM(
                        coordinator: homeCoordinator),
                    coordinator: homeCoordinator
                )
                .environment(\.sharedAlbumViewModel, sharedAlbumViewModel)
            } else {
                SplashView(sharedAlbumViewModel: sharedAlbumViewModel)
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

