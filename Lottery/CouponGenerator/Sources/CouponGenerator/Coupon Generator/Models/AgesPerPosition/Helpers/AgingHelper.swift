//
//  AgingHelper.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 31/12/2024.
//

import Foundation
import Draw

enum AgingHelperError: Error {
    case wrongNumbersCount
}

enum AgingHelper {

    static func agedNumbersBasedOn(_ results: [DrawResult],
                                   drawType: DrawType) -> [AgedNumber] {

        var agedNumbers = Array(1...drawType.validNumberMaxValue).map { AgedNumber(value: $0) }

        let resultsOfInterest: [DrawResult] = results.reversed()

        for (ageAsIdx, result) in resultsOfInterest.enumerated() {
            for number in result.numbers {
                agedNumbers[number.value-1].ages.append(ageAsIdx)
            }
        }

        for (idx, agedNumber) in agedNumbers.enumerated() {
            var previous = 0
            agedNumbers[idx].ages = agedNumber.ages.map { age in
                defer { previous = age }
                return age - previous - 1
            }
        }

        return agedNumbers
    }

    static func agedResultsBasedOn(_ results: [DrawResult], drawType: DrawType) throws -> [DrawResult] {

        guard !results.isEmpty else {
            return []
        }

        var agedResults: [DrawResult] = []

        for (pastResultIdx, pastResult) in results[0...results.count - 1].enumerated() {

            var newNumbers: [AgedNumber] = []

            if pastResultIdx == 0 {
                for number in pastResult.numbers {
                    let numberWithoutAge = AgedNumber(value: number.value)
                    newNumbers.append(numberWithoutAge)
                }
            } else {
                for number in pastResult.numbers {

                    //  let pastResultsSubArray = results[pastResultIdx+1...results.endIndex - 1]
                    let pastResultsEndIdx = max(pastResultIdx - 1, 0)
                    let pastResultsSubArray = results[0...pastResultsEndIdx]

                    if let foundIdx = pastResultsSubArray.lastIndex(where: {$0.containsNumber(number.value)}) {
                        let numberWithAge = AgedNumber(value: number.value, ages: [pastResultIdx - foundIdx - 1])
                        newNumbers.append(numberWithAge)
                    } else {
                        let numberWithoutAge = AgedNumber(value: number.value)
                        newNumbers.append(numberWithoutAge)
                    }
                }
            }

            guard newNumbers.count == drawType.validNumbersCount else {
                throw AgingHelperError.wrongNumbersCount
            }

            do {
                try newNumbers.sort {
                    try AgedNumber.compareByAge(lhs: $0, rhs: $1)
                }
            } catch {
                continue
            }

            newNumbers = newNumbers.enumerated().map { (_, element) in
                AgedNumber(value: element.value, ages: element.ages)
            }

            agedResults.append(drawType.createResult(idx: pastResult.idx, date: pastResult.date, numbers: newNumbers))
        }
        return agedResults
    }

}
