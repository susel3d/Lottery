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
    let roi: ResultsRangeOfInterest

    init(hits: Int, combinations: Int, standardDevFactor: Double, roi: ResultsRangeOfInterest) throws {
        guard hits <= ResultType.validNumbersCount else {
            throw ResultDataError.wrongStatisticsComparatorData
        }
        self.hits = hits
        self.combinations = combinations
        self.standardDevFactor = standardDevFactor
        self.roi = roi
    }

    var debugDescription: String {
        return "hits: \(hits) score: \(combinations), pastResults: \(roi.length), stdDevFactor: \(standardDevFactor)"
    }
}
