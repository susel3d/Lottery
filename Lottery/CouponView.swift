//
//  CouponView.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 13/03/2024.
//

import SwiftUI

struct CouponView: View {

    @ObservedObject var model: ResultsModel

    @State private var showingDeletionAlert = false

    var body: some View {
        List(model.savedCoupons, id: \.self) { result in
            HStack {
                ForEach(result.numbers) { number in
                    SingleNumberInfo(model: model, number: number, showAge: false)
                }
            }
            .swipeActions(edge: .trailing) {
                Button("Delete") {
                    model.clearSavedCoupon(result.idx)
                }
                .tint(.red)
            }
        }
        .onAppear {
            model.loadCoupons()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingDeletionAlert = true
                } label: {
                    Image(systemName: "trash.circle")
                }
            }
        }
        .alert("Are you sure to delete all coupons?", isPresented: $showingDeletionAlert) {
            Button("Dismiss", role: .cancel) { }
            Button("Delete", role: .destructive) {
                model.clearSavedCoupons()
            }
        }
    }
}

#Preview {
    let model = ResultsModel()
    return CouponView(model: model)
}
