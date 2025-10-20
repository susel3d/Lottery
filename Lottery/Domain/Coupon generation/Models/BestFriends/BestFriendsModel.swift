//
//  BestFriendsModel.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 24/08/2025.
//

import Combine

class BestFriendsModel {

    private var drawType: DrawType

    private var roiLength: Int = 0
    private var innerResults: BestFriendsModelResults?
    private var numberFriendliness: [BestFriendNumber]?

    @Published var results: ResultsStatistic?

    init(drawType: DrawType) {
        self.drawType = drawType
    }

    func runFor(commonResults: [DrawResult],
                rangeOfInterestLength: Int) {
        self.roiLength = rangeOfInterestLength
        Task {
            self.innerResults = self.modelResultsBasedOn(commonResults: commonResults)
            results = innerResults?.getFriendshipFactor()
        }
    }

    private func modelResultsBasedOn(commonResults: [DrawResult]) -> BestFriendsModelResults? {
        guard commonResults.count > 0 else {
            return nil
        }

        deriveNumbersFriendliness(commonResults)

        var resultsFriendship: [Double] = []

        for commonResult in commonResults {
            let resultFriendliness = deriveResultFriendliness(commonResult)
            resultsFriendship.append(resultFriendliness)
        }

        guard let (average, deviation) = StatisticsHandler.averageAndStandardDeviationBasedOn(resultsFriendship) else {
            return nil
        }

        let result = ResultsStatistic(average: [average], standardDeviation: [deviation])

        return BestFriendsModelResults(results: result)
    }

    func isResultInScope(_ result: [Int]) -> Bool {
        guard let results,
              let average = results.average.first,
              let standardDeviation = results.standardDeviation.first,
              result.count == drawType.validNumbersCount else {
            return false
        }
        let tempResult = drawType.createResult(idx: 0,
                                                 date: .now,
                                               numbers: result.map {
            BestFriendNumber(value: $0, friendMaxValue: drawType.validNumberMaxValue)
        })
        let friendliness = deriveResultFriendliness(tempResult)

        let inScope = average - standardDeviation < friendliness && friendliness < average + standardDeviation

        return inScope
    }

    fileprivate func deriveResultFriendliness(_ commonResult: DrawResult) -> Double {
        guard let numberFriendliness else {
            return 0
        }
        return commonResult.numbers.indices.map { idx in
            let resultNumber = commonResult.numbers[idx]
            let numberFriendliness = numberFriendliness[resultNumber].friendliness

            return commonResult.numbers[(idx+1)...].reduce(0) { _, number in
                let friendliness = numberFriendliness[number]
                return friendliness
            }
        }.reduce(0, +)
    }

    fileprivate func deriveNumbersFriendliness(_ commonResults: [DrawResult]) {
        var numberFriendliness = Array(1...drawType.validNumberMaxValue).map {
            BestFriendNumber(value: $0, friendMaxValue: drawType.validNumberMaxValue)
        }

        for commonResult in commonResults {
            let concreteTypeResult = commonResult.numbers.compactMap { $0 as? DrawResultNumber }
            for number in concreteTypeResult {
                for theOther in concreteTypeResult where theOther != number {
                    let standarizedValue = 1 / Double(commonResults.count)
                    numberFriendliness[number].addFriend(theOther.value, factor: standarizedValue)
                }
            }
        }

        self.numberFriendliness = numberFriendliness
    }
}
