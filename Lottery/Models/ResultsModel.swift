//
//  Results.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 24/03/2024.
//

import Combine
import Foundation

class ResultsModel: ObservableObject {

    @Published var pastResultToAddManually: Result = .empty()
    @Published var savedCoupons: [Result] = []
    @Published var numbersWithAge: [Number] = []
    @Published var resultsWithAge: [Result] = []
    @Published var futureResult: Result = .empty()

    private var subscriptions = Set<AnyCancellable>()

    init() {
        model.savedCoupons.assign(to: &$savedCoupons)
        model.pastResults.sink { _ in
        } receiveValue: { _ in
            self.updateNumbersAge()
            self.updateResultsAge()
            self.randomizeNextResult()
        }
        .store(in: &subscriptions)
    }

    func loadResults() {
        model.loadData()
    }

    let model = DataModel.shared

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

        guard model.pastResults.value.count > 0 else {
            return
        }

        let count = resultsWithAge.count
        var positionMeanAge = Array(repeating: Int(0), count: Result.validNumbersCount)

        for result in resultsWithAge {
            let sortedAges = result.numbers.compactMap({$0.age}).sorted(by: <)
            positionMeanAge = zip(positionMeanAge, sortedAges).map(+)
        }
        positionMeanAge = positionMeanAge.map { Int($0/count) }

        var futureNumbers: [Number] = []

        for positionAge in positionMeanAge {

            let almostSameAge = numbersWithAge.filter { $0.age! >= positionAge - 1 && $0.age! <= positionAge + 1 }
            if almostSameAge.isEmpty {
                assertionFailure("consider broader variation range")
            }
            var randomNumber: Number?

            repeat {
                randomNumber = almostSameAge.randomElement()
            } while futureNumbers.contains { $0.value == randomNumber?.value ?? -1 }

            if let randomNumber {
                futureNumbers.append(randomNumber)
            }
        }

        futureResult = Result(idx: 0, date: .now, numbers: futureNumbers.sorted(by: >))
    }

    func updateResultsWithAge() {
        if resultsWithAge.isEmpty {
            updateResultsAge()
        }
    }
    func savePastResult() {

    }

    private func updateNumbersAge() {

        let pastResults = model.pastResults.value

        guard pastResults.count > 0 else {
            return
        }

        var resultNumbers = Array(1...Result.validNumberMaxValue).map { Number(value: $0) }

        for (pastResultIdx, pastResult) in pastResults.enumerated() {

            for number in pastResult.numbers {
                // swiftlint:disable:next for_where
                if resultNumbers[number.value-1].age == nil {
                    resultNumbers[number.value-1].age = pastResultIdx
                }
            }

        }
        numbersWithAge = resultNumbers
    }

    private func updateResultsAge() {

        let pastResults = model.pastResults.value

        guard pastResults.count > 0 else {
            return
        }

        var result: [Result] = []

        for (pastResultIdx, pastResult) in pastResults[0...9].enumerated() {

            var newNumbers: [Number] = []

            for number in pastResult.numbers {

                let pastResultsSubArray = pastResults[pastResultIdx+1...pastResults.endIndex-1]

                if let foundIdx = pastResultsSubArray.firstIndex(where: {$0.containsNumber(number.value)}) {
                    let numberWithAge = Number(value: number.value, age: foundIdx-pastResultIdx-1)
                    newNumbers.append(numberWithAge)
                }
            }

            assert(newNumbers.count == Result.validNumbersCount, "Wrong count of result's numbers.")

            result.append(Result(idx: pastResult.idx, date: pastResult.date, numbers: newNumbers))
        }
        resultsWithAge = result
    }

}