//
//  MockDrawResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 16/02/2025.
//

import XCTest
@testable import Lottery

struct MockDrawResult: DrawResult {
    static var type: Lottery.DrawType = .lotto

    var idx: Int
    var numbers: [any Number]
    var date: Date
}
