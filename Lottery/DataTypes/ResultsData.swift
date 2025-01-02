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

struct ResultsData<ResultType: Result> {

    var numbersAgedByLastResult: [Number] = [] // will it be needed?
    var numbersAgedByROIStartIdx: [Number] = []
    var results: [ResultType] = []

    init(numbersAgedByLastResult: [Number],
         numbersAgedByROIStartIdx: [Number] = [],
         results: [ResultType],
         rangeOfIntereset: ResultsRangeOfInterest? = nil) throws {
        self.numbersAgedByLastResult = numbersAgedByLastResult
        self.numbersAgedByROIStartIdx = numbersAgedByROIStartIdx
        self.results = results
        self.rangeOfIntereset = rangeOfIntereset
        try updatePositionsStatistics()
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
        for _ in 0...couponsCount - 1 {
            var coupon: [Int] = []
            var randomNumber: Int
            for position in 0...5 {
                repeat {
                    randomNumber = numbersForAllIterations[position].randomElement()!
                } while coupon.contains { $0 == randomNumber }
                coupon.append(randomNumber)
            }
            coupon.sort(by: <)
            print("coupon: \(coupon)")
        }
    }

    func getNumbers(standardDevFactor: Double = 0.6) -> [[Int]] {
        guard let statistics = positionStatistics else {
            return []
        }

        var numbersForAllIterations: [[Int]] = []

        for position in 0...5 {
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
        var hitsLevels = [4, 5, 6]
        let hitsLevelMin = hitsLevels.min()!
        let hitsLevelMax = hitsLevels.max()!

        for standardDevFactor in [0.5] { //[0.5, 0.6, 0.7, 0.8, 0.9, 1.0] {

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

    private mutating func updatePositionsStatistics() throws {

        guard let rangeOfIntereset else {
            return
        }

        guard rangeOfIntereset.length > 0 && rangeOfIntereset.isScopeValidFor(results) else {
            throw ResultDataError.wrongRangeOfInterestScope
        }

        let resultsOfInterest = results[rangeOfIntereset.startingIdx...rangeOfIntereset.endIdx]
        let ages = resultsOfInterest.map {$0.numbers.compactMap {$0.age}.sorted(by: <)}
        let validAges = ages.filter { $0.count == ResultType.validNumbersCount }

        guard !validAges.isEmpty else {
            return
        }

        var averages = [Double]()
        var deviations = [Double]()

        for positionIdx in 0..<ResultType.validNumbersCount {

            let agesAtPositionIdx = validAges.map { $0[positionIdx] }

            if let statistic = averageAndStandardDeviationBasedOn(agesAtPositionIdx) {
                averages.append(statistic.average)
                deviations.append(statistic.deviation)
            }
        }
        guard averages.count == ResultType.validNumbersCount, deviations.count == ResultType.validNumbersCount else {
            assert(false, "Statistics information is missing")
        }
        positionStatistics = ResultsStatistic(average: averages, standardDeviation: deviations)
    }

    private func averageAndStandardDeviationBasedOn(_ values: [Int]) -> (average: Double, deviation: Double)? {
        var expression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue: values)])

        guard let standardDeviation = expression.expressionValue(with: nil, context: nil) as? Double else {
            assert(false, "Cannot derive stddev value")
            return nil
        }

        expression = NSExpression(forFunction: "average:", arguments: [NSExpression(forConstantValue: values)])
        guard let average = expression.expressionValue(with: nil, context: nil) as? Double else {
            assert(false, "Cannot derive average value")
            return nil
        }

        return (average, standardDeviation)
    }

}
