//
//  AgesPerPositionModelTuner.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 15/02/2025.
//

import Foundation

private let standardDevFactorsToCheck = [0.5, 0.6, 0.7, 0.8]

enum AgesPerPositionModelTuner {

    struct ROIBoundary {
        let startIdxMin = 1
        let startIdxMax = 100
        let lengthMin = 1
        let lengthMax = 100
        let step = 1
    }

    static func tuneStandardDeviationFor(
        commonResults: [DrawResult],
        roi: ROIBoundary = ROIBoundary(),
        drawType: DrawType
    ) -> (stdDev: Double, roiLength: Int)? {

        guard commonResults.count > 0,
              let agedResults = try? AgingHelper.agedResultsBasedOn(commonResults, drawType: drawType) else {
            return nil
        }

        var roiLengths: Set<Int> = []
        var allStatistics: [StatisticsComparatorData] = []
        let agedNumbers = AgingHelper.agedNumbersBasedOn(commonResults, drawType: drawType)

        for roiLength in stride(from: roi.lengthMin, through: roi.lengthMax, by: roi.step) {
            for roiStart in stride(from: roiLength, through: roi.startIdxMax, by: roi.step) {

                roiLengths.insert(roiLength)

                let statisticsStartingIdx = agedResults.count - roiStart - 1

                let statisticsROI = ResultsRangeOfInterest(startingIdx: statisticsStartingIdx, length: roiLength)

                let tempData = try? AgesPerPositionResults(
                    numbersAgedByLastResult: agedNumbers,
                    results: agedResults,
                    rangeOfIntereset: statisticsROI,
                    validNumbersCount: drawType.validNumbersCount)

                if let tempData,
                    let statistic = try? checkResultComplianceWithStats(
                        results: tempData,
                        roi: statisticsROI,
                        validNumbersCount: drawType.validNumbersCount) {
                    allStatistics += statistic
                }
            }
        }

        let countPerStdDevFactor = standardDevFactorsToCheck.map { factor in
            allStatistics.count { $0.standardDevFactor == factor }
        }

        let countPerRoiLength = roiLengths.map { length in
            (length: length, count: allStatistics.count { $0.statisticsROI.length == length })
        }

        guard let bestRoiLength = countPerRoiLength.max(by: { $0.count < $1.count }),
              let (index, _) = countPerStdDevFactor.enumerated().max(by: { $0.element < $1.element })else {
            return (stdDev: 0.7, roiLength: 15)
        }

        return (stdDev: standardDevFactorsToCheck[index], roiLength: bestRoiLength.length)
    }

    static func checkResultComplianceWithStats(
        results: AgesPerPositionResults,
        roi: ResultsRangeOfInterest,
        validNumbersCount: Int
    ) throws -> [StatisticsComparatorData] {

        guard let roiStatistics = results.positionStatistics,
              let roiFirstIndex = results.rangeOfIntereset?.startingIdx else {
            return []
        }

        let resultToCompareIdx = roiFirstIndex + 1

        guard results.count >= resultToCompareIdx, resultToCompareIdx >= 0 else {
            return []
        }

        let resultToCompare = results.results[resultToCompareIdx]

        let concreteResultNumbers = resultToCompare.numbers.compactMap { $0 as? AgedNumber }

        let resultToComparePositionsAges = concreteResultNumbers.compactMap({$0.age}).sorted(by: <)

        var statisticsComparators: [StatisticsComparatorData] = []

        var hitsLevels = Array(validNumbersCount-2...validNumbersCount)
        let (hitsLevelMin, hitsLevelMax) = (hitsLevels.min()!, hitsLevels.max()!)

        for standardDevFactor in standardDevFactorsToCheck {

            var consitency = 0

            for (position, age) in resultToComparePositionsAges.enumerated() {

                let (top, bottom) = getBoundaryFor(roiStatistics: roiStatistics,
                                                   position: position,
                                                   standardDevFactor: standardDevFactor)
                if age <= top && age >= bottom {
                    consitency += 1
                }
            }

            if consitency < hitsLevelMin {
                continue
            }

            let statisticsComparator = try StatisticsComparatorData(
                hits: consitency,
                combinations: 0,
                standardDevFactor: standardDevFactor,
                statisticsROI: roi,
                validNumbersCount: validNumbersCount
            )

            statisticsComparators.append(statisticsComparator)

            hitsLevels.removeAll {$0 == consitency}

            if hitsLevels.isEmpty ||  consitency >= hitsLevelMax {
                break
            }
        }
        return statisticsComparators
    }

    private static func getBoundaryFor(roiStatistics: ResultsStatistic,
                                       position: Int,
                                       standardDevFactor: Double) -> (top: Int, bottom: Int) {
        let average = roiStatistics.average[position]
        let deviation = roiStatistics.standardDeviation[position] * standardDevFactor
        let top = Int(round(average + deviation))
        let bottom = Int(round(max(0, average - deviation)))
        return (top, bottom)
    }
}
