//
//  AgesPerPositionModelTuner.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 15/02/2025.
//

typealias ROIBoundary = (offset: Int, length: Int)

enum AgesPerPositionModelTuner<ResultType: DrawResult> {

    static func tuneModelFor(commonResults: [ResultType],
                             roiMin: ROIBoundary = (offset: 1, length: 1),
                             roiMax: ROIBoundary = (100, 100)) -> Double? {

        return 0.7
        
        guard commonResults.count > 0 else {
            return nil
        }

        let agedNumbers = AgingHelper<ResultType>.agedNumbersBasedOn(commonResults)

        guard let agedResults = try? AgingHelper<ResultType>.agedResultsBasedOn(commonResults) else {
            return nil
        }

        var allStatistics: [StatisticsComparatorData<ResultType>] = []

        for roiLength in roiMin.length...roiMax.length {
            for roiOffset in roiMin.offset...roiMax.offset {

                let statisticsHandler = StatisticsHandler<ResultType>()
                let roi = ResultsRangeOfInterest(startingIdx: roiOffset, length: roiLength)
                let agedNumbersROI = AgingHelper<ResultType>.agedNumbersBasedOn(commonResults, roi: roi)

                if let tempData = try? AgesPerPositionResults(
                    numbersAgedByLastResult: agedNumbers,
                    numbersAgedByROIStartIdx: agedNumbersROI,
                    results: agedResults,
                    rangeOfIntereset: roi,
                    statisticsHandler: statisticsHandler) {
                    if let statistic = try? tempData.checkResultComplianceWithStats(roi: roi) {
                        allStatistics += statistic
                    }
                }
            }
        }

        let combinationsFilter = ResultType.validNumbersCount == 6 ? 5_000_000 : 400_000

        let filter = { (stats: StatisticsComparatorData<ResultType>, hits: Int) -> Bool in
            stats.hits == hits && stats.combinations < combinationsFilter
        }

        let statisticsFor6 = allStatistics.filter { filter($0, ResultType.validNumbersCount) }
        let statisticsFor5 = allStatistics.filter { filter($0, ResultType.validNumbersCount - 1) }
        let statisticsFor4 = allStatistics.filter { filter($0, ResultType.validNumbersCount - 2) }

//        let formatStr = { (stat: StatisticsComparatorData<ResultType>) -> String in
//            "\(stat.roi.length)(\(stat.roi.startingIdx)) \(stat.standardDevFactor)"
//        }

        let param6stdDevFactor = statisticsFor6.map { $0.standardDevFactor }
        let count605 = param6stdDevFactor.count { $0 == 0.5 }
        let count606 = param6stdDevFactor.count { $0 == 0.6 }
        let count607 = param6stdDevFactor.count { $0 == 0.7 }
        let count608 = param6stdDevFactor.count { $0 == 0.8 }

        let param5stdDevFactor = statisticsFor5.map { $0.standardDevFactor }
        let count505 = param5stdDevFactor.count { $0 == 0.5 }
        let count506 = param5stdDevFactor.count { $0 == 0.6 }
        let count507 = param5stdDevFactor.count { $0 == 0.7 }
        let count508 = param5stdDevFactor.count { $0 == 0.8 }

        let param4stdDevFactor = statisticsFor4.map { $0.standardDevFactor }
        let count405 = param4stdDevFactor.count { $0 == 0.5 }
        let count406 = param4stdDevFactor.count { $0 == 0.6 }
        let count407 = param4stdDevFactor.count { $0 == 0.7 }
        let count408 = param4stdDevFactor.count { $0 == 0.8 }

        return 0.7
    }
}
