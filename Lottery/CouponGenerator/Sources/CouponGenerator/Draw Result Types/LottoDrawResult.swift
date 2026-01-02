//
//  LottoResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 31/12/2024.
//

import Draw
import Foundation

struct LottoDrawResult: DrawResult {

    static let type: DrawType = .lotto

    var idx: Int
    let date: Date
    var numbers: [any Number]
}
