//
//  MockDrawResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 16/02/2025.
//

//import XCTest
//@testable import Lottery
//
//struct MockDrawResult: DrawResult {
//    var idx: Int
//    var numbers: [Lottery.Number]
//    var date: Date
//
//    static let sourceFileName = ""
//
//    static let validNumberMaxValue = 42
//    static let validNumbersCount = 5
//
//    static func createResult(idx: Int, date: Date, numbers: [Number]) -> MockDrawResult {
//        return MockDrawResult(idx: idx, numbers: numbers, date: date)
//    }
//
//    func containsNumber(_ number: Int) -> Bool {
//        return numbers.contains { $0.value == number }
//    }
//}
