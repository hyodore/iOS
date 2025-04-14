//
//  Container.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import Foundation

/// Wrap a struct to avoid compile error when have a struct as a property in a same type struct. For example, a property forkFromRepo with type Repo in a Repo struct.
struct Container<T: Codable>: Codable {
    private var values: [T] = []

    init(value: T) {
        self.value = value
    }

    var value: T {
        get {
            values.first!
        }

        set {
            values = [newValue]
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try container.decode(T.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
