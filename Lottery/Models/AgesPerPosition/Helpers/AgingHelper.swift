//
//  AgingHelper.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 31/12/2024.
//

import Foundation

enum AgingHelperError: Error {
    case wrongNumbersCount
}

enum AgingHelper<ResultType: DrawResult> {

    static func agedNumbersBasedOn(_ results: [ResultType],
                                   roi: ResultsRangeOfInterest? = nil) -> [Number] {

        var agedNumbers = Array(1...ResultType.validNumberMaxValue).map { Number(value: $0) }
        var agesSetCounter = 0

        var resultsOfInterest: [ResultType]
        if let roi {
//            resultsOfInterest = Array(results[roi.startingIdx...roi.endIdx].reversed())
            resultsOfInterest = Array(results[roi.startingIdx...].reversed())
        } else {
            resultsOfInterest = results.reversed()
        }

        for (ageAsIdx, result) in resultsOfInterest.enumerated() {

            for number in result.numbers {
                // swiftlint:disable:next for_where
                if agedNumbers[number.value-1].age == nil {
                    agedNumbers[number.value-1].age = ageAsIdx
                    agesSetCounter += 1
                    if agesSetCounter == ResultType.validNumberMaxValue {
                        return agedNumbers
                    }
                }
            }
        }

        return agedNumbers
    }

    static func agedResultsBasedOn(_ results: [ResultType]) throws -> [ResultType] {

        guard !results.isEmpty else {
            return []
        }

        var agedResults: [ResultType] = []

        for (pastResultIdx, pastResult) in results[0...results.count - 1].enumerated() {

            var newNumbers: [Number] = []

            if pastResultIdx == 0 {
                for number in pastResult.numbers {
                    let numberWithoutAge = Number(value: number.value)
                    newNumbers.append(numberWithoutAge)
                }
            } else {
                for number in pastResult.numbers {

                    //  let pastResultsSubArray = results[pastResultIdx+1...results.endIndex - 1]
                    let pastResultsEndIdx = max(pastResultIdx - 1, 0)
                    let pastResultsSubArray = results[0...pastResultsEndIdx]

                    if let foundIdx = pastResultsSubArray.lastIndex(where: {$0.containsNumber(number.value)}) {
                        let numberWithAge = Number(value: number.value, age: pastResultIdx - foundIdx)
                        newNumbers.append(numberWithAge)
                    } else {
                        let numberWithoutAge = Number(value: number.value)
                        newNumbers.append(numberWithoutAge)
                    }
                }
            }

            guard newNumbers.count == ResultType.validNumbersCount else {
                throw AgingHelperError.wrongNumbersCount
            }

            do {
                try newNumbers.sort {
                    try Number.compareByAge(lhs: $0, rhs: $1)
                }
            } catch {
                continue
            }

            newNumbers = newNumbers.enumerated().map { (_, element) in
                Number(value: element.value, age: element.age)
            }

            agedResults.append(ResultType.createResult(idx: pastResult.idx, date: pastResult.date, numbers: newNumbers))
        }
        return agedResults
    }

}
