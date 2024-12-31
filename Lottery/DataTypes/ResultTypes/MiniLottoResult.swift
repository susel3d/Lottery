//
//  MiniLottoResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 31/12/2024.
//

import Foundation

struct MiniLottoResult: Result {

    static func createResult(idx: Int, date: Date, numbers: [Number]) -> MiniLottoResult {
        MiniLottoResult(idx: idx, date: date, numbers: numbers)
    }

    static let validNumbersCount = 5
    static let validNumberMaxValue = 42

    var idx: Int
    let date: Date
    var numbers: [Number]

    func containsNumber(_ number: Int) -> Bool {
        numbers.contains { $0.value == number }
    }

    func numbersAsString() -> String {
        numbers.map {"\($0.value)"}.joined(separator: ",")
    }

}
