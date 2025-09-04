//
//  CouponListViewModelTests.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 04/09/2025.
//

import Testing
@testable import Lottery

final class MockSpeechManager: SpeechManagerProtocol {
    var spokenText: [String] = []
    func speak(_ text: String) {
        spokenText.append(text)
    }
}

@Suite class CouponListViewModelTests {

    @Test
    func testCouponChunking() {
        let coupons = (1...25).map { idx in
            GeneratedCoupon(value: [idx])
        }

        let viewModel = CouponListViewModel(coupons: coupons)

        #expect(viewModel.coupons.count == 3)
        #expect(viewModel.coupons[0].count == 10)
        #expect(viewModel.coupons[1].count == 10)
        #expect(viewModel.coupons[2].count == 5)
    }

    @Test
    func testSpeakCallsSpeechManagerWithCorrectText() {

        let mockSpeechManager = MockSpeechManager()
        let coupon = GeneratedCoupon(value: [1, 5, 10, 15, 23, 30])

        let viewModel = CouponListViewModel(coupons: [coupon], speechManager: mockSpeechManager)

        viewModel.speak(coupon: coupon)

        #expect(mockSpeechManager.spokenText.count == 1)
        #expect(mockSpeechManager.spokenText[0] == "1, 5, 10, 15, 23, 30")
    }
}
