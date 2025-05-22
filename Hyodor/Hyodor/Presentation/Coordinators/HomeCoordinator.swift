//
//  HomeCoordinator.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import SwiftUI

@Observable
class HomeCoordinator{
    var path: [HomeRoute] = []

    enum HomeRoute: Hashable {
        case calendar
        case sharedAlbum
        case Alert
        case AlertDetail(NotificationData)
    }

    func showCalendar() {
        path.append(.calendar)
    }
    func showSharedAlbum() {
        path.append(.sharedAlbum)
    }
    func showAlert() {
        path.append(.Alert)
    }
    func showAlertDetail(_ notification: NotificationData) {
        path.append(HomeRoute.AlertDetail(notification))
    }

}
