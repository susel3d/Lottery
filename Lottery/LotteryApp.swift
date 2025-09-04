//
//  LotteryApp.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 11/03/2024.
//

import SwiftUI

@main
struct LotteryApp: App {

    //let modelsTuner = ModelsTuner<LottoDrawResult>()

    let couponController: CouponController<LottoDrawResult>
    let couponGeneratorViewModel: CouponGeneratorViewModel<LottoDrawResult>

    init() {
        couponController = CouponController<LottoDrawResult>()
        couponGeneratorViewModel = CouponGeneratorViewModel(couponController: couponController)
    }

    var body: some Scene {
        WindowGroup {
            CouponsGeneratorView(viewModel: couponGeneratorViewModel)
        }
    }
}
