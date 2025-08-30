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
        let model3 = BestFriendsModel(commonResults: commonResults)
        Publishers.CombineLatest3(model1.$results, model2.$result, model3.$results)
            .compactMap(unwrapResults)
            .flatMap { result1, result2, _ in
                let generator = CouponGenerator<ResultType>(set: result1, exclusion: result2)
                return generator.generateCouponsPublisher()
            }
            .filter({ coupon in
                model3.isResultInScope(coupon.value)
            })
            .filterOutCouponsByDistance(2)
            .prefix(30)
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

func unwrapResults<T, U, O>(value1: T?, value2: U?, value3: O?) -> (T, U, O)? {
    guard let value1, let value2, let value3 else {
        return nil
    }
    return (value1, value2, value3)
}

extension Publisher where Output == GeneratedCoupon {

}

extension Publisher where Output == GeneratedCoupon {
    func filterOutCouponsByDistance(_ distance: Int) -> AnyPublisher<GeneratedCoupon, Failure> {
        self
            .scan((Set<Set<Int>>(), Optional<GeneratedCoupon>.none)) { state, coupon in
                var (seenSets, _) = state
                let numberSet = Set(coupon.value)

                var skipSet: Bool

                if distance == 0 {
                    skipSet = seenSets.contains(numberSet)
                } else {
                    skipSet = !seenSets.filter( { seenSet in
                        return numberSet.subtracting(seenSet).count <= distance
                    }).isEmpty
                }

                if skipSet {
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
