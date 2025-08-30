//
//  ModelsTuner.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 30/06/2025.
//

import Combine

class ModelsTuner<ResultType: DrawResult> {

    private let commonDataModel = DataModel<ResultType>()
    private var subscriptions = Set<AnyCancellable>()

    init() {
        Task {
            bindForDataReadiness()
            commonDataModel.loadData()
        }
    }

    private func bindForDataReadiness() {
        commonDataModel.pastResults
            .filter { !$0.isEmpty }
            .sink { [weak self] commonResults in
                self?.tuneModels(commonResults)
            }
            .store(in: &subscriptions)
    }

    private func tuneModels(_ commonResults: [ResultType]) {
        tuneAgesPerPosition(commonResults)
    }

    private func tuneAgesPerPosition(_ commonResults: [ResultType]) {
        if let (stdDevFactor, roiLength) = AgesPerPositionModelTuner.tuneStandardDeviationFor(
            commonResults: commonResults
        ) {
            print("\(stdDevFactor), \(roiLength)")
        }
    }

}
