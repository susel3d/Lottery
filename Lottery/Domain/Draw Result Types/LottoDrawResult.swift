//
//  LottoResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 31/12/2024.
//

import Foundation

struct LottoDrawResult: DrawResult {

    static let sourceFileName = "lotto.txt"
    static let validNumbersCount = 6
    static let validNumberMaxValue = 49

    static func createResult(idx: Int, date: Date, numbers: [any Number]) -> LottoDrawResult {
        LottoDrawResult(idx: idx, date: date, numbers: numbers)
    }

    var idx: Int
    let date: Date
    var numbers: [any Number]
}
