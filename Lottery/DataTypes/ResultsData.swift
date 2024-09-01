//
//  ResultsData.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 20/07/2024.
//

import Foundation

struct ResultsStatistic {
    let average: [Int]
    let standardDeviation: [Int]
}

struct ResultsData {

    var numbers: [Number] = []
    var results: [Result] = []

    private(set) var positionStatistics: ResultsStatistic? // = Array(repeating: nil, count: Result.validNumbersCount)

    var count: Int {
        results.count
    }

    func checkStatisticsForLastResult() -> Int? {

        guard let statistics = positionStatistics else {
            return nil
        }

        guard let lastResultPositionsAges = results.first?.numbers.compactMap({$0.age}).sorted(by: <) else {
            return nil
        }

        var consitency = 0

        for (position, age) in lastResultPositionsAges.enumerated() {
            let average = statistics.average[position]
            let deviation = statistics.standardDeviation[position]

            let top = average + deviation
            let bottom = max(0, average - deviation)

            if age <= top && age >= bottom {
                consitency += 1
            }
        }
        print("Statisctics consistency: \(consitency) / \(Result.validNumbersCount)")
        return consitency

    }

    mutating func updatePositionsStatistics() {

        let ages = results.map {$0.numbers.compactMap {$0.age}.sorted(by: <)}
        let validAges = ages.filter { $0.count == Result.validNumbersCount }

        guard !validAges.isEmpty else {
            return
        }

        var averages = [Int]()
        var deviations = [Int]()

        for positionIdx in 0..<Result.validNumbersCount {

            let agesAtPositionIdx = validAges.map { $0[positionIdx] }

            if let statistic = averageAndStandardDeviationBasedOn(agesAtPositionIdx) {
                averages.append(statistic.average)
                deviations.append(statistic.deviation)
            }
        }
        guard averages.count == Result.validNumbersCount, deviations.count == Result.validNumbersCount else {
            assert(false, "Statistics information is missing")
        }
        positionStatistics = ResultsStatistic(average: averages, standardDeviation: deviations)
    }

    private func averageAndStandardDeviationBasedOn(_ values: [Int]) -> (average: Int, deviation: Int)? {
        var expression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue: values)])

        guard let standardDeviationValue = expression.expressionValue(with: nil, context: nil) as? Double else {
            assert(false, "Cannot derive stddev value")
            return nil
        }

        expression = NSExpression(forFunction: "average:", arguments: [NSExpression(forConstantValue: values)])
        guard let averageValue = expression.expressionValue(with: nil, context: nil) as? Double else {
            assert(false, "Cannot derive average value")
            return nil
        }

        let average = Int(round(averageValue))
        let standardDeviation = Int(round(standardDeviationValue))

        return (average, standardDeviation)
    }

}
