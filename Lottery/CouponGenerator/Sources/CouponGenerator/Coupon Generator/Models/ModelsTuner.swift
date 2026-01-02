//
//  ModelsTuner.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 30/06/2025.
//

import Combine
import Draw
import Foundation

struct TuneModelsResult: Codable {
    let stdDevFactor: Double
    let roiLength: Int
}

class ModelsTuner {

    @Published var result: TuneModelsResult?

    private let commonDataModel: DrawDataModel
    private var subscriptions = Set<AnyCancellable>()

    init(dataModel: DrawDataModel) {
        commonDataModel = dataModel
    }

    func tune() {
        Task {
            bindForDataReadiness()
            commonDataModel.loadData()
        }
    }

    private func bindForDataReadiness() {
        commonDataModel.pastResults
            .filter { !$0.isEmpty }
            .sink { [weak self] commonResults in
                if self?.result == nil {
                    self?.tuneModels(commonResults)
                }
                self?.subscriptions.removeAll()
            }
            .store(in: &subscriptions)
    }

    private func tuneModels(_ commonResults: [DrawResult]) {
        tuneAgesPerPosition(commonResults)
    }

    private func saveResultToUserDefaults() {
        let defaults = UserDefaults.standard
        if let encoded = try? JSONEncoder().encode(result) {
            defaults.set(encoded, forKey: commonDataModel.drawType.stringKey)
        }
    }

    private func tuneAgesPerPosition(_ commonResults: [DrawResult]) {
        if let (stdDevFactor, roiLength) = AgesPerPositionModelTuner.tuneStandardDeviationFor(
            commonResults: commonResults,
            drawType: commonDataModel.drawType
        ) {
            result = TuneModelsResult(
                stdDevFactor: stdDevFactor,
                roiLength: roiLength
            )
            saveResultToUserDefaults()
            print("\(stdDevFactor), \(roiLength)")
        }
    }

}
