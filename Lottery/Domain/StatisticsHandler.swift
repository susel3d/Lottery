//
//  ResultsStatistics.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 09/02/2025.
//

import Foundation

struct ResultsStatistic {
    let average: [Double]
    let standardDeviation: [Double]
}

class StatisticsHandler {

    class func updateAgeStatistics(results: [DrawResult],
                                   rangeOfIntereset: ResultsRangeOfInterest,
                                   validNumbersCount: Int) throws -> ResultsStatistic? {

        guard !results.isEmpty else {
            throw ResultDataError.emptyResults
        }

        guard rangeOfIntereset.length > 0 && rangeOfIntereset.isScopeValidFor(results) else {
            throw ResultDataError.wrongRangeOfInterestScope
        }

        let resultsOfInterest = results[rangeOfIntereset.startingIdx...rangeOfIntereset.endIdx]

        let ages = resultsOfInterest.map { $0.numbers.compactMap { ($0 as? AgedNumber)?.age }.sorted(by: <) }
        let validAges = ages.filter { $0.count == validNumbersCount }

        guard !validAges.isEmpty else {
            return nil
        }

        var averages = [Double]()
        var deviations = [Double]()

        for positionIdx in 0..<validNumbersCount {

            let agesAtPositionIdx = validAges.map { $0[positionIdx] }

            if let statistic = averageAndStandardDeviationBasedOn(agesAtPositionIdx) {
                averages.append(statistic.average)
                deviations.append(statistic.deviation)
            }
        }

        guard averages.count == validNumbersCount, deviations.count == validNumbersCount else {
            assert(false, "Statistics information is missing")
        }
        return ResultsStatistic(average: averages, standardDeviation: deviations)
    }

    static func averageAndStandardDeviationBasedOn(_ values: [any Numeric]) -> (average: Double, deviation: Double)? {
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
