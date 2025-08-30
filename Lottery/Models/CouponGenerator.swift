//
//  CouponGenerator.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 11/05/2025.
//

import Combine

struct GeneratedCoupon {
    let value: [Int]
}

class CouponGenerator<ResultType: DrawResult> {
    private let set: [[Int]]
    private let exclusion: [Int]

    init(set: [[Int]], exclusion: [Int]) {
        self.set = set
        self.exclusion = exclusion
    }

    func generateCouponsPublisher() -> AnyPublisher<GeneratedCoupon, Never> {
        let subject = PassthroughSubject<GeneratedCoupon, Never>()
        //let filteredNumbers = set.flatMap { $0 }.filter { !exclusion.contains($0) }

        Task {
            while true {
                try? await Task.sleep(for: .seconds(0.05))
                Task {
                    subject.send(prepareCoupon())
                }
            }
            subject.send(completion: .finished)
        }
        return subject.eraseToAnyPublisher()
    }

    private func prepareCoupon() -> GeneratedCoupon {
        var coupon: [Int] = []
        var randomNumber: Int
        for position in 0...ResultType.validNumbersCount - 1 {
            repeat {
                randomNumber = set[position].randomElement()!
            } while coupon.contains { $0 == randomNumber }
            coupon.append(randomNumber)
        }
        coupon.sort(by: <)
        return GeneratedCoupon(value: coupon)
    }
}
