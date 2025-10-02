//
//  CouponGeneratorViewModel.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 02/09/2025.
//

import Combine
import Foundation

enum Progress {
    case progress(Double)
    case timeout
}

@Observable
class CouponGeneratorViewModel {

    var timeout: TimeInterval = 30
    var couponMinDistance = 3
    var couponsCount = 10
    var maxCalidNumbersCount = 0

    var progress: Progress = .progress(0)
    var isGenerating = false
    var generatedCoupons: [GeneratedCoupon] = []
    var canGenerateCoupons = false

    private var cancellables = Set<AnyCancellable>()

    private let couponController: CouponController

    init(couponController: CouponController) {

        self.couponController = couponController

        maxCalidNumbersCount = couponController.validNumbersCount

        self.couponController.$commonDataReady
            .receive(on: RunLoop.main)
            // assign doesn't update View with Observable VM
            .sink(receiveValue: { [weak self] dataReady in
                self?.canGenerateCoupons = dataReady
            })
            .store(in: &cancellables)

        self.couponController.$generatedCoupons
            .assign(to: \.generatedCoupons, on: self)
            .store(in: &cancellables)

        self.couponController.$progress
            .sink(receiveValue: { [weak self] progress in
                self?.progress = .progress(progress)
                if progress == 1 {
                    if self?.generatedCoupons.count != self?.couponsCount {
                        self?.progress = .timeout
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.isGenerating = false
                    }
                }
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
        self.progress = .progress(0)
        couponController.cancelGeneration()
    }

    func setDrawType(drawType: DrawType) {
        dispatchAppAction(.changeDrawType(drawType))
    }
}
