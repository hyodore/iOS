//
//  Event.swift
//  Hyodor
//
//  Created by 김상준 on 4/30/25.
//

import Foundation

struct Schedule: Codable, Identifiable {
    let id: UUID
    var title: String
    var date: Date
    var notes: String?

    init(id: UUID = UUID(), title: String, date: Date, notes: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.notes = notes
    }
}
