//
//  Results.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 24/03/2024.
//

import Combine
import Foundation

class ResultsModel: ObservableObject {

    @Published var data = ResultsData()

    @Published var pastResultToAddManually: Result = .empty()
    @Published var savedCoupons: [Result] = []
    @Published var futureResult: Result = .empty()

    // TODO Data can be full, limited only by View presentation
    private var resultsListCount: Int { DataModel.shared.pastResults.value.count }

    private var subscriptions = Set<AnyCancellable>()

    private let model = DataModel.shared

    init() {
        model.savedCoupons.assign(to: &$savedCoupons)
        model.pastResults.sink { _ in
        } receiveValue: { _ in
            self.updateResultsData()
            self.randomizeNextResult()
        }
        .store(in: &subscriptions)
    }

    func loadResults() {
        model.loadData()
    }

    func saveCoupon() {
        let nextIdx = (savedCoupons.last?.idx ?? 0) + 1
        let numbers = futureResult.numbersAsString()
        model.saveCoupon(idx: nextIdx, numbers: numbers)
        loadCoupons()
    }

    func loadCoupons() {
        model.loadCoupons()
    }

    func clearSavedCoupons() {
        model.clearSavedCoupons()
        model.loadCoupons()
    }

    func clearSavedCoupon(_ couponIdx: Int) {
        model.clearSavedCoupon(couponIdx)
        model.loadCoupons()
    }

    func randomizeNextResult() {
        if let random = ResultRandomizer.randomFor(data) {
            futureResult = random
        }
    }

    private func updateResultsData() {
        let pastResults = model.pastResults.value

        guard pastResults.count > 0 else {
            return
        }
        // TODO Rework..
        data.numbers = agedNumbersBasedOn(pastResults)
        data.results = agedResultsBasedOn(pastResults)

        data.updatePositionsStatistics()
        // TODO move to separate View / V indicator
        let result = data.checkStatisticsForLastResult()
    }

    private func agedNumbersBasedOn(_ results: [Result]) -> [Number] {

        var agedNumbers = Array(1...Result.validNumberMaxValue).map { Number(value: $0) }

        for (ageAsIdx, result) in results.enumerated() {

            for number in result.numbers {
                // swiftlint:disable:next for_where
                if agedNumbers[number.value-1].age == nil {
                    agedNumbers[number.value-1].age = ageAsIdx
                }
            }
        }

        return agedNumbers
    }

    private func agedResultsBasedOn(_ results: [Result]) -> [Result] {

        var agedResults: [Result] = []

        for (pastResultIdx, pastResult) in results[0...resultsListCount - 1].enumerated() {

            var newNumbers: [Number] = []

            if pastResultIdx == results.endIndex - 1 {
                for number in pastResult.numbers {
                    let numberWithAge = Number(value: number.value)
                    newNumbers.append(numberWithAge)
                }
            } else {
                for number in pastResult.numbers {

                    let pastResultsSubArray = results[pastResultIdx+1...results.endIndex - 1]

                    if let foundIdx = pastResultsSubArray.firstIndex(where: {$0.containsNumber(number.value)}) {
                        let numberWithAge = Number(value: number.value, age: foundIdx-pastResultIdx-1)
                        newNumbers.append(numberWithAge)
                    } else {
                        let numberWithAge = Number(value: number.value)
                        newNumbers.append(numberWithAge)
                    }
                }
            }

            assert(newNumbers.count == Result.validNumbersCount, "Wrong count of result's numbers.")

            agedResults.append(Result(idx: pastResult.idx, date: pastResult.date, numbers: newNumbers))
        }
        return agedResults
    }
}
