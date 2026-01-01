//
//  AgedNumber.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/01/2026.
//

enum AgedNumberError: Error {
    case compareWithAgeEmpty
}

struct AgedNumber: Number, Comparable {
    static func < (lhs: AgedNumber, rhs: AgedNumber) -> Bool {
        lhs.value < rhs.value
    }

    static func compareByAge(lhs: AgedNumber, rhs: AgedNumber) throws -> Bool {
        guard let lhsAge = lhs.age, let rhsAge = rhs.age else {
            throw AgedNumberError.compareWithAgeEmpty
        }
        return lhsAge < rhsAge
    }

    let value: Int
    var age: Int? {
        ages.first
    }
    var ages: [Int] = []

    static func empty() -> AgedNumber {
        AgedNumber(value: 0)
    }
}
