//
//  Number.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 15/03/2024.
//

import Foundation

struct Number: Hashable, Comparable, Identifiable {
    var id = UUID()
    static func < (lhs: Number, rhs: Number) -> Bool {
        lhs.value > rhs.value
    }

    let value: Int
    var age: Int?

    static func empty() -> Number {
        Number(id: UUID(), value: 0, age: nil)
    }
}
