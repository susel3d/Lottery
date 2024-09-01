//
//  ResultRandomizer.swift
//  Lottery
//
//  Created by Lukasz.Kmiotek on 2024-05-13.
//

import Foundation

class ResultRandomizer {

    private init() {

    }

    static func randomFor(_ data: ResultsData) -> Result? {

        let numbers = data.numbers

        guard !numbers.isEmpty else {
            return nil
        }

        guard let average = data.positionStatistics?.average, !average.isEmpty,
              let deviation = data.positionStatistics?.standardDeviation, !deviation.isEmpty,
                average.count == deviation.count else {
            return nil
        }

        var futureNumbers: [Number] = []

        for (positionIdx, ageAtPosition) in average.enumerated() {
            let bottomAge = max(0, ageAtPosition - deviation[positionIdx])
            let topAge = ageAtPosition + deviation[positionIdx]
            let almostSameAge = numbers.filter { $0.age! >= bottomAge && $0.age! <= topAge }
            if almostSameAge.isEmpty {
                return nil
            }
            var randomNumber: Number?

            repeat {
                randomNumber = almostSameAge.randomElement()
            } while futureNumbers.contains { $0.value == randomNumber?.value ?? -1 }

            if let randomNumber {
                futureNumbers.append(randomNumber)
            }
        }

        let result = Result(idx: 0, date: .now, numbers: futureNumbers.sorted(by: <))
        return result
    }
}
