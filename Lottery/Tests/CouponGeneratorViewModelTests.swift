//
//  MockCouponController.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 04/09/2025.
//

import Combine
import Foundation
import Testing
@testable import Lottery

// MARK: - Mocks

final class MockCouponController: CouponController {
    @Published var mockCommonDataReady: Bool = false
    @Published var mockProgress: Double = 0
    @Published var mockGeneratedCoupons: [GeneratedCoupon] = []

    private var cancellables = Set<AnyCancellable>()

    override init(dataModel: DrawDataModel) {
        super.init(dataModel: dataModel)

        $mockCommonDataReady
            .sink { [weak self] in self?.commonDataReady = $0 }
            .store(in: &cancellables)

        $mockProgress
            .sink { [weak self] in self?.progress = $0 }
            .store(in: &cancellables)

        $mockGeneratedCoupons
            .sink { [weak self] in self?.generatedCoupons = $0 }
            .store(in: &cancellables)
    }

    var generateCalled = false
    var cancelCalled = false


    override func generateCoupons(timeout: TimeInterval,
                                  couponDistance: Int,
                                  couponsCount: Int,
                                  historyDeepth: Int,
                                  standardDevFactor: Double) {
        generateCalled = true
    }

    override func cancelGeneration() {
        cancelCalled = true
    }
}

// MARK: - Unit Test Suite

@Suite
struct CouponGeneratorViewModelTests {

    let drawDataModel = DrawDataModel(drawType: .lotto)

    @Test
    func testInitialState() {
        let controller = MockCouponController(dataModel: drawDataModel)
        let viewModel = CouponsGeneratorViewModel(couponController: controller)

        #expect(viewModel.progress.value == 0)
        #expect(viewModel.generatedCoupons.isEmpty)
        #expect(viewModel.canGenerateCoupons == false)
        #expect(viewModel.isGenerating == false)
    }

    @Test
    func testGenerateCouponsCallsControllerAndSetsFlag() {
        let controller = MockCouponController(dataModel: drawDataModel)
        let viewModel = CouponsGeneratorViewModel(couponController: controller)

        viewModel.generateCoupons()

        #expect(viewModel.isGenerating == true)
        #expect(controller.generateCalled == true)
    }

    @Test
    func testCancelGenerationResetsState() {
        let controller = MockCouponController(dataModel: drawDataModel)
        let viewModel = CouponsGeneratorViewModel(couponController: controller)

        viewModel.isGenerating = true
        viewModel.progress = .progress(0.8)

        viewModel.cancelGeneration()

        #expect(viewModel.isGenerating == false)
        #expect(viewModel.progress.value == 0)
        #expect(controller.cancelCalled == true)
    }

    @Test
    func testClearCouponsEmptiesGeneratedCoupons() {
        let controller = MockCouponController(dataModel: drawDataModel)
        let viewModel = CouponsGeneratorViewModel(couponController: controller)

        viewModel.generatedCoupons = [coupon1, coupon2]
        viewModel.clearCoupons()

        #expect(viewModel.generatedCoupons.isEmpty)
    }

    @Test
    func testBindingCommonDataReadyAndProgress() async throws {
        let controller = MockCouponController(dataModel: drawDataModel)
        let viewModel = CouponsGeneratorViewModel(couponController: controller)

        controller.mockCommonDataReady = true
        controller.mockProgress = 0.5

        try await Task.sleep(for: .seconds(0.1))

        #expect(viewModel.canGenerateCoupons == true)
        #expect(viewModel.progress.value == 0.5)
    }

    private let coupon1 = GeneratedCoupon(value: [1, 2, 3, 4, 5, 6])
    private let coupon2 = GeneratedCoupon(value: [21, 22, 23, 24, 25, 26])
}
