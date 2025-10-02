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

enum DrawType {

    case lotto
    case miniLotto

    var validNumbersCount: Int {
        switch self {
        case .lotto:
            6
        case .miniLotto:
            5
        }
    }

    var validNumberMaxValue: Int {
        switch self {
        case .lotto:
            49
        case .miniLotto:
            42
        }
    }

    var sourceFileName: String {
        switch self {
        case .lotto:
            "lotto.txt"
        case .miniLotto:
            "miniLotto.txt"
        }
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

    func emptyResult() -> any DrawResult {
        var numbers: [DrawResultNumber] = []
        for _ in 0...validNumbersCount-1 {
            numbers.append(DrawResultNumber.empty())
        }
        return createResult(idx: 0, date: .now, numbers: numbers)
    }
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

enum DrawResultHelper {

    static func resultsFrom(lines: [String], type: DrawType) throws -> [any DrawResult] {

        var results: [any DrawResult] = []

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"

        for line in lines {

            if line.isEmpty {
                throw DataParsingError.emptyLine
            }

            let components = line.components(separatedBy: .whitespaces)

            guard components.count == LineComponent.allCases.count else {
                throw DataParsingError.missingComponent
            }

            guard let id = Int(components[.id].trimmingCharacters(in: .punctuationCharacters)),
                  let date = dateFormatter.date(from: components[.date]) else {
                throw DataParsingError.wrongComponent
            }

            let numbersStringArray = components[.numbers].components(separatedBy: ",")
            let numbersIntArray = numbersStringArray.compactMap { Int($0) }

            if numbersIntArray.count != type.validNumbersCount {
                throw DataParsingError.wrongNumbersCount
            }

            let numbers = numbersIntArray.map { DrawResultNumber(value: $0) }

            results.append(type.createResult(idx: id, date: date, numbers: numbers))
            // results.append(Result(idx: id, date: date, numbers: numbers))
        }

        return results
    }

    static func numbersFromString(_ string: String, type: DrawType) throws -> [any Number] {
        let numbers = string.components(separatedBy: ",").compactMap {Int($0)}
        if numbers.count != type.validNumbersCount {
            throw ResultError.wrongNumbersCount
        }
        if numbers.first(where: {$0 > type.validNumberMaxValue || $0 < 1}) != nil {
            throw ResultError.wrongNumbersRange
        }
        return numbers.map {DrawResultNumber(value: $0)}
    }
}

private enum LineComponent: CaseIterable {

    case id, date, numbers

    func position() -> Int {
        switch self {
        case .id:
            0
        case .date:
            1
        case .numbers:
            2
        }
    }
}

private extension Array where Element == String {
    subscript(_ component: LineComponent) -> String {
        self[component.position()]
    }
}
