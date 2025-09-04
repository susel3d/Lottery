//
//  WithoutNumbersModel.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 11/02/2025.
//

import Combine

class ExclusionModel<ResultType: DrawResult> {

    @Published var result: [Int]?

    init(commonResults: [ResultType]) {
        Task {
            result = self.modelResultsBasedOn(commonResults: commonResults)
        }
    }

    private func modelResultsBasedOn(commonResults: [ResultType]) -> [Int] {

        var modelResult: [Int] = []

        guard commonResults.count > 0 else {
            return modelResult
        }

        guard let results = try? AgingHelper<ResultType>.agedResultsBasedOn(commonResults) else {
            return modelResult
        }

        let resultsCount = Double(results.count)

        for result in results {

            let concreteTypeResult = result.numbers.compactMap { $0 as? AgedNumber }

            let ages = concreteTypeResult.compactMap({ $0.age })

            guard ages.count == ResultType.validNumbersCount, let min = ages.min() else {
                continue
            }

            modelResult.append(min)
        }

        let result0Count = modelResult.count(where: {$0 == 0})
        let result1Count = modelResult.count(where: {$0 == 1})
        let result2Count = modelResult.count(where: {$0 == 2})
        let result3Count = modelResult.count(where: {$0 == 3})
        let result4Count = modelResult.count(where: {$0 == 4})
        let result5Count = modelResult.count(where: {$0 == 5})

//        print("0: \(Double(result0Count)/resultsCount)")
//        print("1: \(Double(result1Count)/resultsCount)")
//        print("2: \(Double(result2Count)/resultsCount)")
//        print("3: \(Double(result3Count)/resultsCount)")
//        print("4: \(Double(result4Count)/resultsCount)")
//        print("5: \(Double(result5Count)/resultsCount)")

        return modelResult
    }

    // protocol name doesnt fit here
    func prepareCoupon() {
        // exclude numbers only from last draw
        
    }
}
