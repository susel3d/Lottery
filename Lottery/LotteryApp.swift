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

    let couponController = CouponController<LottoDrawResult>()

    var body: some Scene {
        WindowGroup {
            EmptyView()
        }
    }
}
