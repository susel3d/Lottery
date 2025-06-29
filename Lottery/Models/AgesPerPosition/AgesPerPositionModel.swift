//
//  Results.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 24/03/2024.
//

import Combine
import Foundation

class AgesPerPositionModel<ResultType: DrawResult>: FutureDraw {

    private let roiLength: Int

    private var results: AgesPerPositionResults<ResultType>?
    private var stdDevForCoupon: Double?

    @Published var result: [[Int]]?

    private init() {
        roiLength = 0
    }

    init(commonResults: [ResultType],
         rangeOfInterestLength: Int = 40) {
        self.roiLength = rangeOfInterestLength
        Task {
            self.results = self.modelResultsBasedOn(commonResults: commonResults)
            self.tuneModelFor(commonResults: commonResults)
            result = results?.getNumbers()
        }
    }

    private func modelResultsBasedOn(commonResults: [ResultType]) -> AgesPerPositionResults<ResultType>? {
        guard commonResults.count > 0 else {
            return nil
        }

        let statisticsHandler = StatisticsHandler<ResultType>()
        let roi = ResultsRangeOfInterest(startingIdx: 0, length: roiLength)

        return try? AgesPerPositionResults(
            numbersAgedByLastResult: AgingHelper<ResultType>.agedNumbersBasedOn(commonResults),
            numbersAgedByROIStartIdx: AgingHelper<ResultType>.agedNumbersBasedOn(commonResults, roi: roi),
            results: AgingHelper<ResultType>.agedResultsBasedOn(commonResults),
            rangeOfIntereset: roi,
            statisticsHandler: statisticsHandler
        )
    }

    private func tuneModelFor(commonResults: [ResultType]) {
        stdDevForCoupon = AgesPerPositionModelTuner.tuneModelFor(
            commonResults: commonResults
        )
    }
}
