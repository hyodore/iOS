//
//  CalendarCoordinator.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import Foundation

// MARK: - Coordinator
@Observable
class CalendarCoordinator{
    var showAddEvent: Bool = false

    func presentAddEvent() {
        showAddEvent = true
    }
    func dismissAddEvent() {
        showAddEvent = false
    }
}
