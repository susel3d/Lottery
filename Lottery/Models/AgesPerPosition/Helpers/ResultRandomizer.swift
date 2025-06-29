//
//  ResultRandomizer.swift
//  Lottery
//
//  Created by Lukasz.Kmiotek on 2024-05-13.
//

import Foundation

class ResultRandomizer<ResultType: DrawResult> {

    private init() {}

    static func randomFor(_ data: AgesPerPositionResults<ResultType>) -> ResultType? {

        let numbers = data.numbersAgedByLastResult

        guard !numbers.isEmpty else {
            return nil
        }

        guard let average = data.positionStatistics?.average, !average.isEmpty,
              let deviation = data.positionStatistics?.standardDeviation, !deviation.isEmpty,
                average.count == deviation.count else {
            return nil
        }

        var futureNumbers: [Number] = []

        for (positionIdx, meanAgeAtPosition) in average.enumerated() {
            let bottomAge = Int(round(max(0, meanAgeAtPosition - deviation[positionIdx])))
            let topAge = Int(round(meanAgeAtPosition + deviation[positionIdx]))
            let numbersWithinScope = numbers.filter { $0.age! >= bottomAge && $0.age! <= topAge }
            if numbersWithinScope.isEmpty {
                return nil
            }
            var randomNumber: Number?

            repeat {
                randomNumber = numbersWithinScope.randomElement()
            } while futureNumbers.contains { $0.value == randomNumber?.value ?? -1 }

            if let randomNumber {
                futureNumbers.append(randomNumber)
            }
        }

        let result = ResultType.createResult(idx: 0, date: .now, numbers: futureNumbers.sorted(by: <))
        return result
    }
}
