//
//  Publisher+Utils.swift
//  Hyodor
//
//  Created by 김상준 on 4/14/25.
//

import Combine

extension Publisher {
    func optionalize() -> Publishers.Map<Self, Self.Output?> {
        map({ Optional.some($0) })
    }
}
