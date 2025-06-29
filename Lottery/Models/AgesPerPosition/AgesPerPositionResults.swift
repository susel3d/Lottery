//
//  ResultsData.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 20/07/2024.
//

import Foundation

enum ResultDataError: Error {
    case wrongRangeOfInterestScope
    case wrongStatisticsComparatorData
}

struct ResultsStatistic {
    let average: [Double]
    let standardDeviation: [Double]
}

struct AgesPerPositionResults<ResultType: DrawResult> {

    var numbersAgedByLastResult: [Number] = []
    var numbersAgedByROIStartIdx: [Number] = []
    var results: [ResultType] = []

    private let statisticsHandler: StatisticsHandler<ResultType>

    init(numbersAgedByLastResult: [Number],
         numbersAgedByROIStartIdx: [Number] = [],
         results: [ResultType],
         rangeOfIntereset: ResultsRangeOfInterest? = nil,
         statisticsHandler: StatisticsHandler<ResultType>) throws {
        self.numbersAgedByLastResult = numbersAgedByLastResult
        self.numbersAgedByROIStartIdx = numbersAgedByROIStartIdx
        self.results = results
        self.rangeOfIntereset = rangeOfIntereset
        self.statisticsHandler = statisticsHandler
        self.positionStatistics = try self.statisticsHandler.updatePositionsStatistics(results: results,
                                                             rangeOfIntereset: rangeOfIntereset)
    }

    private var rangeOfIntereset: ResultsRangeOfInterest?
    private(set) var positionStatistics: ResultsStatistic?

    private var count: Int {
        results.count
    }

    func getNumbersFullfiling(statistics: ResultsStatistic,
                              for position: Int,
                              standardDevFactor: Double) -> (range: (top: Int, bottom: Int), numbers: [Number]) {
        let average = statistics.average[position]
        let deviation = statistics.standardDeviation[position] * standardDevFactor

        let top = Int(round(average + deviation))
        let bottom = Int(round(max(0, average - deviation)))

        let limitedNumberIteration = numbersAgedByROIStartIdx.filter {
            guard let age = $0.age else {
                return false
            }
            return age <= top && age >= bottom
        }
        return (range: (top, bottom), numbers: limitedNumberIteration)
    }

    func prepareCoupon(couponsCount: Int = 10, stdDev: Double = 0.6) {
        let numbersForAllIterations = getNumbers(standardDevFactor: stdDev)
        var coupons: [[Int]] = []
        for _ in 0...couponsCount - 1 {
            var coupon: [Int]
            repeat {
                coupon = []
                var randomNumber: Int
                for position in 0...ResultType.validNumbersCount - 1 {
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

    func getNumbers(standardDevFactor: Double = 0.6) -> [[Int]] {
        guard let statistics = positionStatistics else {
            return []
        }

        var numbersForAllIterations: [[Int]] = []

        for position in 0...ResultType.validNumbersCount - 1 {
            let (_, numbersFullfilingStats) = getNumbersFullfiling(statistics: statistics,
                                                              for: position,
                                                              standardDevFactor: standardDevFactor)
            let numbersForIteration = numbersFullfilingStats.map { $0.value }.sorted(by: <)
            numbersForAllIterations.append(numbersForIteration)
        }
        return numbersForAllIterations
    }

    func checkResultComplianceWithStats(roi: ResultsRangeOfInterest) throws -> [StatisticsComparatorData<ResultType>] {

        guard let roiStatistics = positionStatistics,
              let roiFirstIndex = rangeOfIntereset?.startingIdx else {
            return []
        }

        let resultToCompareIdx = roiFirstIndex - 1

        guard results.count >= resultToCompareIdx, resultToCompareIdx >= 0 else {
            return []
        }

        let resultToCompare = results[resultToCompareIdx]
        let resultToComparePositionsAges = resultToCompare.numbers.compactMap({$0.age}).sorted(by: <)

        var statisticsComparators: [StatisticsComparatorData<ResultType>] = []

        var hitsLevels = Array(ResultType.validNumbersCount-2...ResultType.validNumbersCount)
        let hitsLevelMin = hitsLevels.min()!
        let hitsLevelMax = hitsLevels.max()!

        for standardDevFactor in [0.5, 0.6, 0.7, 0.8] {

            var consitency = 0

            for (position, age) in resultToComparePositionsAges.enumerated() {

                let average = roiStatistics.average[position]
                let deviation = roiStatistics.standardDeviation[position] * standardDevFactor
                let top = Int(round(average + deviation))
                let bottom = Int(round(max(0, average - deviation)))

                if age <= top && age >= bottom {
                    consitency += 1
                }
            }

            if consitency < hitsLevelMin ||
                statisticsComparators.contains(where: {$0.hits == consitency}) {
                continue
            }

            let statisticsComparator = try StatisticsComparatorData<ResultType>(
                hits: consitency,
                combinations: 0,
                standardDevFactor: standardDevFactor,
                roi: roi)
            statisticsComparators.append(statisticsComparator)

            hitsLevels.removeAll {$0 == consitency}

            if hitsLevels.isEmpty ||  consitency >= hitsLevelMax {
                break
            }
        }
        return statisticsComparators
    }

}
