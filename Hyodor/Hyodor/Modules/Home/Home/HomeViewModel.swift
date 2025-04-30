//
//  HomeViewModel.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import Foundation

@Observable
class HomeViewModel{
    // Coordinator를 주입받음
    let coordinator: HomeCoordinator

    init(coordinator: HomeCoordinator) {
        self.coordinator = coordinator
    }

    // 버튼 액션
    func didTapCalendar() {
        coordinator.showCalendar()
    }
    func didTapSharedAlbum() {
        coordinator.showSharedAlbum()
    }
    func didTapAlert() {
        coordinator.showAlert()
    }
}
