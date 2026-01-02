//
//  DrawResultHelper.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/01/2026.
//

import Draw
import Foundation

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
