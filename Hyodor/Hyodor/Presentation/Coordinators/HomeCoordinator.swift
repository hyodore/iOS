//
//  HomeCoordinator.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

@Observable
class HomeCoordinator{
    // 어떤 화면으로 이동할지 상태로 관리
    var path: [HomeRoute] = []

    enum HomeRoute: Hashable {
        case calendar
        case sharedAlbum
        case Alert
    }

    // 네비게이션 액션
    func showCalendar() {
        path.append(.calendar)
    }
    func showSharedAlbum() {
        path.append(.sharedAlbum)
    }
    func showAlert() {
        path.append(.Alert)
    }
}
