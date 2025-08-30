//
//  StatisticsComparatorData.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/12/2024.
//

import Foundation

struct StatisticsComparatorData<ResultType: DrawResult>: CustomDebugStringConvertible {

    let hits: Int
    let combinations: Int
    let standardDevFactor: Double
    let statisticsROI: ResultsRangeOfInterest

    init(hits: Int, combinations: Int, standardDevFactor: Double, statisticsROI: ResultsRangeOfInterest) throws {
        guard hits <= ResultType.validNumbersCount else {
            throw ResultDataError.wrongStatisticsComparatorData
        }
        self.hits = hits
        self.combinations = combinations
        self.standardDevFactor = standardDevFactor
        self.statisticsROI = statisticsROI
    }

    var debugDescription: String {
        return "hits: \(hits) score: \(combinations), pastResults: \(statisticsROI.length), stdDevFactor: \(standardDevFactor)"
    }
}
