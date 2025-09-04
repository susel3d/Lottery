//
//  Results.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 24/03/2024.
//

import Combine
import Foundation

class AgesPerPositionModel<ResultType: DrawResult> {

    private let roiLength: Int
    private var innerResults: AgesPerPositionResults<ResultType>?

    @Published var results: [[Int]]?

    private init() {
        roiLength = 0
    }

    init(commonResults: [ResultType],
         rangeOfInterestLength: Int = 15) {
        self.roiLength = rangeOfInterestLength
        Task {
            self.innerResults = self.modelResultsBasedOn(commonResults: commonResults)
            results = innerResults?.getNumbers()
        }
    }

    private func modelResultsBasedOn(commonResults: [ResultType]) -> AgesPerPositionResults<ResultType>? {
        guard commonResults.count > 0 else {
            return nil
        }

        guard let results = try? AgingHelper<ResultType>.agedResultsBasedOn(commonResults) else {
            return nil
        }

        let startingIdx = results.count - roiLength

        let roi = ResultsRangeOfInterest(startingIdx: startingIdx, length: roiLength)

        let numbersAgedByLastResult = AgingHelper<ResultType>.agedNumbersBasedOn(results)
        let numbersAgedByROIStartIdx = AgingHelper<ResultType>.agedNumbersBasedOn(results, roi: roi)

        return try? AgesPerPositionResults(
            numbersAgedByLastResult: numbersAgedByLastResult,
            numbersAgedByROIStartIdx: numbersAgedByROIStartIdx,
            results: results,
            rangeOfIntereset: roi
        )
    }
}
