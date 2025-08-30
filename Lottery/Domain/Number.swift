//
//  Number.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 15/03/2024.
//

import Foundation

enum NumberError: Error {
    case compareWithAgeEmpty
}

struct Number: Hashable, Comparable {

    let value: Int
    var age: Int?
    var friendliness: [Double] = Array(repeating: 0, count: 49)

    static func < (lhs: Number, rhs: Number) -> Bool {
        lhs.value < rhs.value
    }

    mutating func addFriend(_ friendValue: Int, factor: Double) {
        guard friendValue != value else { return }
        friendliness[friendValue - 1] += factor
    }

    static func compareByAge(lhs: Number, rhs: Number) throws -> Bool {
        guard let lhsAge = lhs.age, let rhsAge = rhs.age else {
            throw NumberError.compareWithAgeEmpty
        }
        return lhsAge < rhsAge
    }

    static func empty() -> Number {
        Number(value: 0)
    }

}

extension Array {
    subscript(number: Number) -> Element {
        get {
            return self[number.value - 1]
        }
        set {
            self[number.value - 1] = newValue
        }
    }
}
