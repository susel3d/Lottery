//
//  LottoResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 31/12/2024.
//

import Foundation

struct LottoResult: Result {

    static func createResult(idx: Int, date: Date, numbers: [Number]) -> LottoResult {
        LottoResult(idx: idx, date: date, numbers: numbers)
    }

    static let validNumbersCount = 6
    static let validNumberMaxValue = 49

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
