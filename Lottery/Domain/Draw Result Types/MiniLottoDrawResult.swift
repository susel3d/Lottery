//
//  MiniLottoResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 31/12/2024.
//

import Foundation

struct MiniLottoDrawResult: DrawResult {

    static let sourceFileName = "miniLotto.txt"
    static let validNumbersCount = 5
    static let validNumberMaxValue = 42

    static func createResult(idx: Int, date: Date, numbers: [Number]) -> MiniLottoDrawResult {
        MiniLottoDrawResult(idx: idx, date: date, numbers: numbers)
    }

    var idx: Int
    let date: Date
    var numbers: [Number]

}
