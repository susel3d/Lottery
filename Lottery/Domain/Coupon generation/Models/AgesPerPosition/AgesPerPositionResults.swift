//
//  ResultsData.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 20/07/2024.
//

import Foundation

enum ResultDataError: Error {
    case emptyResults
    case wrongRangeOfInterestScope
    case wrongStatisticsComparatorData
}

struct AgesPerPositionResults {

    var numbersAgedByLastResult: [AgedNumber] = []
    var results: [DrawResult] = []
    let validNumbersCount: Int

    init(numbersAgedByLastResult: [AgedNumber],
         results: [DrawResult],
         rangeOfIntereset: ResultsRangeOfInterest,
         validNumbersCount: Int) throws {
        self.numbersAgedByLastResult = numbersAgedByLastResult
        self.results = results
        self.rangeOfIntereset = rangeOfIntereset
        self.validNumbersCount = validNumbersCount
        self.positionStatistics = try StatisticsHandler.updateAgeStatistics(
            results: results,
            rangeOfIntereset: rangeOfIntereset,
            validNumbersCount: validNumbersCount)
    }

    private(set) var rangeOfIntereset: ResultsRangeOfInterest?
    private(set) var positionStatistics: ResultsStatistic?

    var count: Int {
        results.count
    }

    func getNumbersFullfiling(statistics: ResultsStatistic,
                              for position: Int,
                              standardDevFactor: Double) -> (range: (top: Int, bottom: Int), numbers: [AgedNumber]) {
        let average = statistics.average[position]
        let deviation = statistics.standardDeviation[position] * standardDevFactor

        let top = Int(round(average + deviation))
        let bottom = Int(round(max(0, average - deviation)))

        let limitedNumberIteration = numbersAgedByLastResult.filter {
            guard let age = $0.age else {
                return false
            }
            return age <= top && age >= bottom
        }
        return (range: (top, bottom), numbers: limitedNumberIteration)
    }

    func prepareCoupon(couponsCount: Int, stdDev: Double) {
        let numbersForAllIterations = getNumbers(standardDevFactor: stdDev)
        var coupons: [[Int]] = []
        for _ in 0...couponsCount - 1 {
            var coupon: [Int]
            repeat {
                coupon = []
                var randomNumber: Int
                for position in 0...validNumbersCount - 1 {
                    repeat {
                        randomNumber = numbersForAllIterations[position].randomElement()!
                    } while coupon.contains { $0 == randomNumber }
                    coupon.append(randomNumber)
                }
                coupon.sort(by: <)
            } while coupons.contains(coupon)
            coupons.append(coupon)
            print(coupon)
        }
    }

    func getNumbers(standardDevFactor: Double) -> [[Int]] {
        guard let statistics = positionStatistics else {
            return []
        }

        var numbersForAllIterations: [[Int]] = []

        for position in 0...validNumbersCount - 1 {
            let (_, numbersFullfilingStats) = getNumbersFullfiling(statistics: statistics,
                                                              for: position,
                                                              standardDevFactor: standardDevFactor)
            let numbersForIteration = numbersFullfilingStats.map { $0.value }.sorted(by: <)
            numbersForAllIterations.append(numbersForIteration)
        }
        return numbersForAllIterations
    }

}
