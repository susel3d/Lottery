//
//  CouponGeneratorViewModel.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 02/09/2025.
//

import Combine
import Foundation

@Observable
class CouponGeneratorViewModel<ResultType: DrawResult> {

    var progress: Double = 0
    var timeout: TimeInterval = 30
    var couponMinDistance = 2
    var couponsCount = 10
    var isGenerating = false
    var generatedCoupons: [GeneratedCoupon] = []
    var canGenerateCoupons = false

    private var cancellables = Set<AnyCancellable>()

    private let couponController: CouponController<ResultType>

    init(couponController: CouponController<ResultType>) {
        self.couponController = couponController
        self.couponController.$commonDataReady.assign(to: \.canGenerateCoupons, on: self)
            .store(in: &cancellables)
        self.couponController.$progress.assign(to: \.progress, on: self)
            .store(in: &cancellables)
        self.couponController.$generatedCoupons
            .filter { !$0.isEmpty }
            .sink(receiveValue: { generatedCoupons in
                self.isGenerating = false
                self.progress = 0
                self.generatedCoupons = generatedCoupons
            })
            .store(in: &cancellables)
    }

    func generateCoupons() {
        isGenerating = true
        couponController.generateCoupons(timeout: timeout,
                                         couponDistance: couponMinDistance,
                                         couponsCount: couponsCount)
    }

    func clearCoupons() {
        generatedCoupons.removeAll()
    }

    func cancelGeneration() {
        self.isGenerating = false
        self.progress = 0
        couponController.cancelGeneration()
    }
}
