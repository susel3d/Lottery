//
//  BestFriendNumber.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/01/2026.
//


struct BestFriendNumber: Number {
    let value: Int
    var friendliness: [Double]

    init(value: Int, friendMaxValue: Int) {
        self.value = value
        self.friendliness = Array(repeating: 0, count: friendMaxValue)
    }

    static func empty() -> BestFriendNumber {
        BestFriendNumber(value: 0, friendMaxValue: 0)
    }

    mutating func addFriend(_ friendValue: Int, factor: Double) {
        guard friendValue != value else { return }
        friendliness[friendValue - 1] += factor
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
