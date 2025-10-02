//
//  LotteryApp.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 11/03/2024.
//

import SwiftUI

@main
struct LotteryApp: App {

    let stateStore = StateStore()
    let diContainer: DependencyInjection

    // let modelsTuner = ModelsTuner<LottoDrawResult>()

    init() {
        diContainer = DependencyInjection()
    }

    var body: some Scene {
        WindowGroup {
            @State var viewModel = resolveDI(CouponGeneratorViewModel.self)
            CouponsGeneratorView(viewModel: viewModel)
        }
    }
}
