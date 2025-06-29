//
//  Number.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 15/03/2024.
//

import Foundation

struct Number: Hashable, Comparable, Identifiable {

    let value: Int
    var age: Int?

    // TODO: is it required only for View? If yes then rework
    var id = UUID()
    static func < (lhs: Number, rhs: Number) -> Bool {
        lhs.value < rhs.value
    }

    static func empty() -> Number {
        Number(value: 0, age: nil, id: UUID())
    }
}
