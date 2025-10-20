//
//  WithoutNumbersModel.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 11/02/2025.
//

import Combine

class ExclusionModel {

    private var drawType: DrawType

    @Published var result: [Int]?

    init(drawType: DrawType) {
        self.drawType = drawType
    }

    func runFor(commonResults: [DrawResult]) {
        Task {
            result = self.modelResultsBasedOn(commonResults: commonResults)
        }
    }

    private func modelResultsBasedOn(commonResults: [DrawResult]) -> [Int] {

//        var modelResult: [Int] = []
//
//        guard commonResults.count > 0 else {
//            return modelResult
//        }
//
//        guard let results = try? AgingHelper.agedResultsBasedOn(commonResults, drawType: drawType) else {
//            return modelResult
//        }
//
//        for result in results {
//
//            let ages = result.numbers.compactMap { ($0 as? AgedNumber)?.age }
//
//            guard ages.count == drawType.validNumbersCount, let min = ages.min() else {
//                continue
//            }
//
//            modelResult.append(min)
//        }
//
//        let result0Count = modelResult.count(where: {$0 == 0})
//        let result1Count = modelResult.count(where: {$0 == 1})
//        let result2Count = modelResult.count(where: {$0 == 2})
//        let result3Count = modelResult.count(where: {$0 == 3})
//        let result4Count = modelResult.count(where: {$0 == 4})
//        let result5Count = modelResult.count(where: {$0 == 5})
//
//        return modelResult

        guard commonResults.count > 0 else {
            return []
        }

        // exclude numbers only from last draw
        return commonResults.last!.numbers.map { $0.value }
    }
}
