//
//  CouponController.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 09/02/2025.
//

import Combine

class CouponController<ResultType: DrawResult> {

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
                self?.prepareCoupons(commonResults)
            }
            .store(in: &subscriptions)
    }
    
    private func prepareCoupons(_ commonResults: [ResultType]) {
        let model1 = AgesPerPositionModel(commonResults: commonResults)
        let model2 = ExclusionModel(commonResults: commonResults)
        Publishers.CombineLatest(model1.$result, model2.$result)
            .compactMap(unwrapResults)
            .flatMap { result1, result2 in
                let generator = CouponGenerator<ResultType>(set: result1, exclusion: result2)
                return generator.generateCouponsPublisher()
            }
            .filterOutDuplicatedCoupons()
            .prefix(100)
            .collect()
            .sink { coupons in
                for coupon in coupons {
                    print("\(coupon.value )")
                }
            }
            .store(in: &subscriptions)
    }

    func saveCoupon() {
//        let nextIdx = (savedCoupons.last?.idx ?? 0) + 1
//        let numbers = futureResult.numbersAsString()
//        model.saveCoupon(idx: nextIdx, numbers: numbers)
//        loadCoupons()
    }

    //    func saveCoupon() {
    //        let nextIdx = (savedCoupons.last?.idx ?? 0) + 1
    //        let numbers = futureResult.numbersAsString()
    //        model.saveCoupon(idx: nextIdx, numbers: numbers)
    //        loadCoupons()
    //    }
    //
    //    func loadCoupons() {
    //        model.loadCoupons()
    //    }
    //
    //    func clearSavedCoupons() {
    //        model.clearSavedCoupons()
    //        model.loadCoupons()
    //    }
    //
    //    func clearSavedCoupon(_ couponIdx: Int) {
    //        model.clearSavedCoupon(couponIdx)
    //        model.loadCoupons()
    //    }

    func loadCoupons() {
        commonDataModel.loadCoupons()
    }

    func clearSavedCoupons() {
        commonDataModel.clearSavedCoupons()
        commonDataModel.loadCoupons()
    }

    func clearSavedCoupon(_ couponIdx: Int) {
        commonDataModel.clearSavedCoupon(couponIdx)
        commonDataModel.loadCoupons()
    }
}

// MARK: - Helpers

func unwrapResults<T, U>(value1: T?, value2: U?) -> (T, U)? {
    guard let value1, let value2 else {
        return nil
    }
    return (value1, value2)
}

extension Publisher where Output == GeneratorCoupon {
    func filterOutDuplicatedCoupons() -> AnyPublisher<GeneratorCoupon, Failure> {
        self
            .scan((Set<Set<Int>>(), Optional<GeneratorCoupon>.none)) { state, coupon in
                var (seenSets, _) = state
                let numberSet = Set(coupon.value)

                if seenSets.contains(numberSet) {
                    return (seenSets, nil)
                } else {
                    seenSets.insert(numberSet)
                    return (seenSets, coupon)
                }
            }
            .compactMap { $0.1 }
            .eraseToAnyPublisher()
    }
}
