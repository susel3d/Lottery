//
//  BestFriendsModel.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 24/08/2025.
//

import Combine

class BestFriendsModel<ResultType: DrawResult>: FutureDraw {

    private let roiLength: Int
    private var innerResults: BestFriendsModelResults<ResultType>?
    private var numberFriendliness: [Number]?

    @Published var results: ResultsStatistic?

    init(commonResults: [ResultType],
         rangeOfInterestLength: Int = 15) {
        self.roiLength = rangeOfInterestLength
        Task {
            self.innerResults = self.modelResultsBasedOn(commonResults: commonResults)
            results = innerResults?.getFriendshipFactor()
        }
    }
    
    private func modelResultsBasedOn(commonResults: [ResultType]) -> BestFriendsModelResults<ResultType>? {
        guard commonResults.count > 0 else {
            return nil
        }

        deriveNumbersFriendliness(commonResults)

        var resultsFriendship: [Double] = []

        for commonResult in commonResults {
            let resultFriendliness = deriveResultFriendliness(commonResult)
            resultsFriendship.append(resultFriendliness)
        }

        guard let (average, deviation) = StatisticsHandler<ResultType>.averageAndStandardDeviationBasedOn(resultsFriendship) else {
            return nil
        }

        let result = ResultsStatistic(average: [average], standardDeviation: [deviation])

        return BestFriendsModelResults(results: result)
    }

    func isResultInScope(_ result: [Int]) -> Bool {
        guard let results,
              let average = results.average.first,
              let standardDeviation = results.standardDeviation.first,
              result.count == ResultType.validNumbersCount else {
            return false
        }
        let tempResult = ResultType.createResult(idx: 0, date: .now, numbers: result.map { Number(value: $0) })
        let friendliness = deriveResultFriendliness(tempResult)

        let inScope = average - standardDeviation < friendliness && friendliness < average + standardDeviation

        return inScope
    }

    fileprivate func deriveResultFriendliness(_ commonResult: ResultType) -> Double {
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

    fileprivate func deriveNumbersFriendliness(_ commonResults: [ResultType]) {
        var numberFriendliness = Array(1...ResultType.validNumberMaxValue).map { Number(value: $0) }

        for commonResult in commonResults {
            for number in commonResult.numbers {
                for theOther in commonResult.numbers where theOther != number {
                    let standarizedValue = 1 / Double(commonResults.count)
                    numberFriendliness[number].addFriend(theOther.value, factor: standarizedValue)
                }
            }
        }

        self.numberFriendliness = numberFriendliness
    }
}
