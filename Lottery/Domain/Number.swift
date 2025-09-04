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

protocol Number: Hashable {
    var value: Int { get }
}

struct DrawResultNumber: Number, Comparable {

    static func < (lhs: DrawResultNumber, rhs: DrawResultNumber) -> Bool {
        lhs.value < rhs.value
    }

    let value: Int

    static func empty() -> DrawResultNumber {
        DrawResultNumber(value: 0)
    }
}

struct BestFriendNumber<ResultType: DrawResult>: Number {
    let value: Int
    var friendliness: [Double] = Array(repeating: 0, count: ResultType.validNumberMaxValue)

    static func empty() -> BestFriendNumber {
        BestFriendNumber(value: 0)
    }

    mutating func addFriend(_ friendValue: Int, factor: Double) {
        guard friendValue != value else { return }
        friendliness[friendValue - 1] += factor
    }
}

struct AgedNumber: Number, Comparable {
    static func < (lhs: AgedNumber, rhs: AgedNumber) -> Bool {
        lhs.value < rhs.value
    }

    static func compareByAge(lhs: AgedNumber, rhs: AgedNumber) throws -> Bool {
        guard let lhsAge = lhs.age, let rhsAge = rhs.age else {
            throw NumberError.compareWithAgeEmpty
        }
        return lhsAge < rhsAge
    }

    let value: Int
    var age: Int?

    static func empty() -> AgedNumber {
        AgedNumber(value: 0, age: 0)
    }
}

extension Array {
    subscript(number: any Number) -> Element {
        get {
            return self[number.value - 1]
        }
        set {
            self[number.value - 1] = newValue
        }
    }
}
