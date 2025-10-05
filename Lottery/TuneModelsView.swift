//
//  TuneModelsView.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 04/10/2025.
//

import SwiftUI

struct TuneModelsView: View {

    @Bindable var viewModel = TuneModelsViewModel()

    var body: some View {
        Text("TODO...")
            .font(.title)
            .padding()
            .onAppear {
                viewModel.tune()
            }
    }
}

@Observable
class TuneModelsViewModel {

    let modelTuner: ModelsTuner

    init(modelTuner: ModelsTuner = resolveDI(ModelsTuner.self)) {
        self.modelTuner = modelTuner
    }

    func tune() {
        modelTuner.tune()
    }
}
