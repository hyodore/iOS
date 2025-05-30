//
//  String+Utils.swift
//  Hyodor
//
//  Created by 김상준 on 4/25/25.
//

import Foundation
import CryptoKit

extension String {
    func sha256() -> String {
        let data = Data(self.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
