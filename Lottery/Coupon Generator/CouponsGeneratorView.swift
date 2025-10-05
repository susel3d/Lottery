//
//  CouponsGeneratorView.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/09/2025.
//

import Observation
import SwiftUI

struct CouponsGeneratorView: View {

    @Bindable var viewModel: CouponsGeneratorViewModel
    @State private var showList = false
    @State private var showOptions = false

    var body: some View {
        Form {
            generatorSettingsSection
            modelSettingsSection
            actionButtonsSection
        }
        .navigationTitle("Coupon Generator")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showOptions = true
                }, label: {
                    Image(systemName: "gear")
                })
            }
        }
        .disabled(viewModel.isGenerating)
        .overlay(loadingOverlay)
        .navigationDestination(isPresented: $showList) {
            CouponListView(viewModel: CouponListViewModel(coupons: viewModel.generatedCoupons))
        }
        .confirmationDialog("Choose an option", isPresented: $showOptions, titleVisibility: .visible) {
            Button("Lotto") {
                viewModel.setDrawType(drawType: .lotto)
            }
            Button("Mini Lotto") {
                viewModel.setDrawType(drawType: .miniLotto)
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var generatorSettingsSection: some View {
        Section(header: Text("Generator Settings")) {
            Stepper("Timeout: \(Int(viewModel.timeout))s",
                    value: $viewModel.timeout,
                    in: 5...120,
                    step: 5)
            Stepper("Coupon Distance: \(viewModel.couponMinDistance)",
                    value: $viewModel.couponMinDistance,
                    in: 1...viewModel.maxCalidNumbersCount)
            Stepper("Coupons to Generate: \(viewModel.couponsCount)",
                    value: $viewModel.couponsCount,
                    in: 10...100,
                    step: 10)
        }
    }

    @ViewBuilder
    private var modelSettingsSection: some View {

        Section(header: Text("Model Settings")) {

            Stepper("History deepth: \(viewModel.historyDeepth)",
                    value: $viewModel.historyDeepth,
                    in: 1...100,
                    step: 1)
            Stepper(value: $viewModel.stdandardDeviation,
                    in: 0.1...1.0,
                    step: 0.1) {
                Text("Standard deviation: \(viewModel.stdandardDeviation, specifier: "%.1f")")
               }
        }
    }

    @ViewBuilder
    private var actionButtonsSection: some View {
        Section {
            generateButton()
            clearCouponsButton
            showCouponsButton
        }
    }

    @ViewBuilder
    private func generateButton() -> some View {
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
