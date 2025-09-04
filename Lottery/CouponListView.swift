//
//  CouponListView.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 03/09/2025.
//

import SwiftUI

struct CouponListView: View {

    @Bindable var viewModel: CouponListViewModel
    @State private var currentIndexPath = IndexPath(row: 0, section: 0)

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                List {
                    ForEach(viewModel.coupons.indices, id: \.self) { section in
                        Section {
                            ForEach(viewModel.coupons[section].indices, id: \.self) { row in
                                let indexPath = IndexPath(row: row, section: section)
                                listItemFor(indexPath: indexPath)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .onChange(of: currentIndexPath) { _, newIndexPath in
                    speakCurrentCoupon()
                    scrollProxy.scrollTo(newIndexPath, anchor: .center)
                }
                .onAppear {
                    speakCurrentCoupon()
                }
            }.navigationBarTitleDisplayMode(.inline)

            HStack(spacing: 40) {
                Button(action: moveUp) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 24))
                }

                Button(action: moveDown) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 24))
                }
            }
            .padding()
        }
    }

    @ViewBuilder
    func listItemFor(indexPath: IndexPath) -> some View {
        let coupon = viewModel.coupons[indexPath.section][indexPath.row]
        let isCurrent = indexPath == currentIndexPath

        Text(coupon.toString())
            .foregroundColor(isCurrent ? .black : .gray.opacity(0.33))
            .id(indexPath)
    }

    func speakCurrentCoupon() {
        let coupon = viewModel.coupons[currentIndexPath.section][currentIndexPath.row]
        viewModel.speak(coupon: coupon)
    }

    func moveUp() {
        var section = currentIndexPath.section
        var row = currentIndexPath.row

        if row > 0 {
            row -= 1
        } else if section > 0 {
            section -= 1
            row = viewModel.coupons[section].count - 1
        } else {
            return
        }

        currentIndexPath = IndexPath(row: row, section: section)
    }

    func moveDown() {
        var section = currentIndexPath.section
        var row = currentIndexPath.row

        if row < viewModel.coupons[section].count - 1 {
            row += 1
        } else if section < viewModel.coupons.count - 1 {
            section += 1
            row = 0
        } else {
            return
        }

        currentIndexPath = IndexPath(row: row, section: section)
    }

}

// MARK: - Preview

struct CouponListView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCoupons = [
            GeneratedCoupon(value: [5, 12, 19, 23, 31, 42]),
            GeneratedCoupon(value: [1, 4, 7, 14, 28, 39]),
            GeneratedCoupon(value: [3, 6, 9, 18, 27, 36]),
            GeneratedCoupon(value: [10, 20, 30, 40, 50, 60]),
            GeneratedCoupon(value: [2, 8, 16, 24, 32, 48])
        ]
        let vm = CouponListViewModel(coupons: sampleCoupons)
        CouponListView(viewModel: vm)
    }
}
