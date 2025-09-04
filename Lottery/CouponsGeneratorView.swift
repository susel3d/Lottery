//
//  CouponsGeneratorView.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/09/2025.
//

import Observation
import SwiftUI

struct CouponsGeneratorView<ResultType: DrawResult>: View {

    @Bindable var viewModel: CouponGeneratorViewModel<ResultType>
    @State private var showList = false

    var body: some View {
        NavigationStack {
            Form {
                settingsSection
                actionButtonsSection
            }
            .navigationTitle("Coupon Generator")
            .disabled(viewModel.isGenerating)
            .overlay(loadingOverlay)
            .navigationDestination(isPresented: $showList) {
                CouponListView(viewModel: CouponListViewModel(coupons: viewModel.generatedCoupons))
            }
        }
    }

    private var settingsSection: some View {
        Section(header: Text("Generator Settings")) {
            Stepper("Timeout: \(Int(viewModel.timeout))s",
                    value: $viewModel.timeout,
                    in: 5...120,
                    step: 5)
            Stepper("Coupon Distance: \(viewModel.couponMinDistance)",
                    value: $viewModel.couponMinDistance,
                    in: 1...ResultType.validNumbersCount)
            Stepper("Coupons to Generate: \(viewModel.couponsCount)",
                    value: $viewModel.couponsCount,
                    in: 10...100,
                    step: 10)
        }
    }

    private var actionButtonsSection: some View {
        Section {
            generateButton
            clearCouponsButton
            showCouponsButton
        }
    }

    private var generateButton: some View {
        Button("Generate Coupons") {
            viewModel.generateCoupons()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .disabled(viewModel.isGenerating || !viewModel.canGenerateCoupons || !viewModel.generatedCoupons.isEmpty)
    }

    private var clearCouponsButton: some View {
        Button("Clear Coupons") {
            viewModel.clearCoupons()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .disabled(viewModel.isGenerating || viewModel.generatedCoupons.isEmpty)
    }

    private var showCouponsButton: some View {
        Button("Show Coupons") {
            showList = true
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .disabled(viewModel.isGenerating || viewModel.generatedCoupons.isEmpty)
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if viewModel.isGenerating {
            CouponsGeneratorProgresView(progress: $viewModel.progress, stopGeneration: viewModel.cancelGeneration)
        }
    }
}
