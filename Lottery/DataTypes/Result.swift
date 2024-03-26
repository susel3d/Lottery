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

struct Result: Hashable {

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

extension Result {

    static func numbersFromString(_ string: String) throws -> [Number] {
        let numbers = string.components(separatedBy: ",").compactMap {Int($0)}
        if numbers.count != validNumbersCount {
            throw ResultError.wrongNumbersCount
        }
        if numbers.first(where: {$0 > validNumberMaxValue || $0 < 1}) != nil {
            throw ResultError.wrongNumbersRange
        }
        return numbers.map {Number(value: $0, age: 0)}
    }

    static func empty() -> Result {
        var numbers: [Number] = []
        for _ in 0...validNumbersCount-1 {
            numbers.append(Number.empty())
        }
        return Result(idx: 0, date: .now, numbers: numbers)
    }

    static func resultsFrom(lines: [String]) throws -> [Result] {

        var results: [Result] = []

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

            if numbersIntArray.count != validNumbersCount {
                throw DataParsingError.wrongNumbersCount
            }

            let numbers = numbersIntArray.map { Number(value: $0, age: 0) }

            results.append(Result(idx: id, date: date, numbers: numbers))
        }

        return results
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
