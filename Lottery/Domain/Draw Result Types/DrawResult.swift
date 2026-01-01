//
//  Result.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 15/03/2024.
//

import Foundation

enum ResultError: Error {
    case wrongNumbersCount
    case wrongNumbersRange
}

enum DataParsingError: Error {
    case emptyLine
    case missingComponent
    case wrongComponent
    case wrongNumbersCount
}

protocol DrawResult {

    static var type: DrawType { get }

    var idx: Int { get set }
    var date: Date { get }
    var numbers: [any Number] { get set }
}

extension DrawResult {
    func containsNumber(_ number: Int) -> Bool {
        numbers.contains { $0.value == number }
    }

    func numbersAsString() -> String {
        numbers.map {"\($0.value)"}.joined(separator: ",")
    }
}
extension DrawType {
    func createResult(idx: Int, date: Date, numbers: [any Number]) -> DrawResult {
        switch self {
        case .lotto:
            LottoDrawResult(idx: idx, date: date, numbers: numbers)
        case .miniLotto:
            MiniLottoDrawResult(idx: idx, date: date, numbers: numbers)
        }
    }

    func createResult(idx: Int, date: Date, numbers: [AgedNumber]) -> DrawResult {
        switch self {
        case .lotto:
            LottoDrawResult(idx: idx, date: date, numbers: numbers)
        case .miniLotto:
            MiniLottoDrawResult(idx: idx, date: date, numbers: numbers)
        }
    }

    func emptyResult() -> any DrawResult {
        var numbers: [DrawResultNumber] = []
        for _ in 0...validNumbersCount-1 {
            numbers.append(DrawResultNumber.empty())
        }
        return createResult(idx: 0, date: .now, numbers: numbers)
    }
}

