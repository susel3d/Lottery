//
//  Results.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 24/03/2024.
//

import Combine
import Foundation

class AgesPerPositionModel {

    private var drawType: DrawType
    private var roiLength = 0
    private var innerResults: AgesPerPositionResults?

    @Published var results: [[Int]]?

    init(drawType: DrawType) {
        self.drawType = drawType
    }

    func runFor(commonResults: [DrawResult],
                rangeOfInterestLength: Int = 20) {
        self.roiLength = rangeOfInterestLength
        Task {
            self.innerResults = self.modelResultsBasedOn(commonResults: commonResults)
            results = innerResults?.getNumbers()
        }
    }

    private func modelResultsBasedOn(commonResults: [DrawResult]) -> AgesPerPositionResults? {
        guard commonResults.count > 0 else {
            return nil
        }

        guard let results = try? AgingHelper.agedResultsBasedOn(commonResults, drawType: drawType) else {
            return nil
        }

        let startingIdx = results.count - roiLength

        let roi = ResultsRangeOfInterest(startingIdx: startingIdx, length: roiLength)

        let numbersAgedByLastResult = AgingHelper.agedNumbersBasedOn(results, drawType: drawType)
        let numbersAgedByROIStartIdx = AgingHelper.agedNumbersBasedOn(results, roi: roi, drawType: drawType)

        return try? AgesPerPositionResults(
            numbersAgedByLastResult: numbersAgedByLastResult,
            numbersAgedByROIStartIdx: numbersAgedByROIStartIdx,
            results: results,
            rangeOfIntereset: roi,
            validNumbersCount: drawType.validNumbersCount
        )
    }
}
