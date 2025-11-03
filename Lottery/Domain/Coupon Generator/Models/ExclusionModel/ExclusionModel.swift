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

        var modelResult: [Int] = []

        let agedNumbers: [AgedNumber] = AgingHelper.agedNumbersBasedOn(commonResults, drawType: drawType)

        // The 5 numbers that were drawn most often in 15 draws

        modelResult = agedNumbers.sorted { (number1: AgedNumber, number2: AgedNumber) in
            let count1 = number1.ages.prefix(15).reduce(0, +)
            let count2 = number2.ages.prefix(15).reduce(0, +)
            return count1 < count2
        }.prefix(5).map { $0.value }

        return modelResult
    }
}
