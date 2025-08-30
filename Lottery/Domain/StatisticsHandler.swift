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

class StatisticsHandler<ResultType: DrawResult> {

    static func updateAgeStatistics(results: [ResultType],
                             rangeOfIntereset: ResultsRangeOfInterest?) throws -> ResultsStatistic? {

        guard let rangeOfIntereset else {
            return nil
        }

        guard rangeOfIntereset.length > 0 && rangeOfIntereset.isScopeValidFor(results) else {
            throw ResultDataError.wrongRangeOfInterestScope
        }

        let resultsOfInterest = results[rangeOfIntereset.startingIdx...rangeOfIntereset.endIdx]
        let ages = resultsOfInterest.map {$0.numbers.compactMap {$0.age}.sorted(by: <)}
        let validAges = ages.filter { $0.count == ResultType.validNumbersCount }

        guard !validAges.isEmpty else {
            return nil
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
