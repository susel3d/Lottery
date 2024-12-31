//
//  Results.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 24/03/2024.
//

// mini

import Combine
import Foundation

class ResultsModel<ResultType: Result>: ObservableObject {

    @Published var data: ResultsData<ResultType>?

    @Published var pastResultToAddManually = ResultType.empty()
    @Published var savedCoupons: [ResultType] = []
    @Published var futureResult = ResultType.empty()

    private var resultsListCount: Int { model.pastResults.value.count }

    private var subscriptions = Set<AnyCancellable>()

    private let model = DataModel<ResultType>()

    private var stdDevForCoupon: Double?

    init() {
        model.savedCoupons.assign(to: &$savedCoupons)
        model.pastResults.sink { _ in
            self.updateResultsData()
            self.randomizeNextResult()
            self.prepareCoupon()
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
        guard let data else {
            return
        }
        if let random = ResultRandomizer<ResultType>.randomFor(data) {
            futureResult = random
        }
    }

    private func updateResultsData() {
        let pastResults = model.pastResults.value

        guard pastResults.count > 0 else {
            return
        }

        let roi = ResultsRangeOfInterest(startingIdx: 0, length: 40)

        data = try? ResultsData(
            numbersAgedByLastResult: AgingHelper<ResultType>.agedNumbersBasedOn(pastResults),
            numbersAgedByROIStartIdx: AgingHelper<ResultType>.agedNumbersBasedOn(pastResults, roi: roi),
            results: AgingHelper<ResultType>.agedResultsBasedOn(pastResults),
            rangeOfIntereset: roi
        )

    }

    func prepareCoupon() {
        if stdDevForCoupon == nil {
            // TODO: rate method results and return it
            stdDevForCoupon = findBestParameters()
        }
        guard let stdDevForCoupon else {
            return
        }
        data?.prepareCoupon(stdDev: stdDevForCoupon)
    }

    private func findBestParameters() -> Double? {

        guard stdDevForCoupon == nil else {
            return stdDevForCoupon
        }
        let results = model.pastResults.value

        guard results.count > 0 else {
            return nil
        }

        let agedNumbers = AgingHelper<ResultType>.agedNumbersBasedOn(results)
        let agedResults = AgingHelper<ResultType>.agedResultsBasedOn(results)

        var allStatistics: [StatisticsComparatorData<ResultType>] = []
        let roiMinimum = (offseet: 1, length: 1)

        for roiLength in roiMinimum.length...100 {
            for roiOffset in roiMinimum.offseet...100 {

                let roi = ResultsRangeOfInterest(startingIdx: roiOffset, length: roiLength)

                let agedNumbersROI = AgingHelper<ResultType>.agedNumbersBasedOn(results, roi: roi)

                if let tempData = try? ResultsData(
                    numbersAgedByLastResult: agedNumbers,
                    numbersAgedByROIStartIdx: agedNumbersROI,
                    results: agedResults,
                    rangeOfIntereset: roi) {
                    if let statistic = try? tempData.checkResultComplianceWithStats(roi: roi) {
                        allStatistics += statistic
                    }
                }
            }
        }

        let filter = { (stats: StatisticsComparatorData<ResultType>, hits: Int) -> Bool in
            stats.hits == hits && stats.combinations < 5_000_000
        }

        let statisticsFor6 = allStatistics.filter { filter($0, 6) }
        let statisticsFor5 = allStatistics.filter { filter($0, 5) }
        let statisticsFor4 = allStatistics.filter { filter($0, 4) }

        let formatStr = { (stat: StatisticsComparatorData<ResultType>) -> String in
            "\(stat.roi.length)(\(stat.roi.startingIdx)) \(stat.standardDevFactor)"
        }
        let param = allStatistics.map { formatStr($0) }

        let param6 = statisticsFor6.map { formatStr($0) }
        let param5 = statisticsFor5.map { formatStr($0)}
        let param4 = statisticsFor4.map { formatStr($0)}

        print("##########")

        return 0.6
    }
}
