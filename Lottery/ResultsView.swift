//
//  ResultsView.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 12/03/2024.
//

import SwiftUI

struct ResultsView: View {

    @ObservedObject var model: ResultsModel<LottoResult>

    var body: some View {
        List {
            HStack {
                ForEach(model.futureResult.numbers) { number in
                    SingleNumberInfo(model: model, number: number, isFuture: true)
                }
            }
            .swipeActions(edge: .leading) {
                Button("Next!") {
                    model.randomizeNextResult()
                }
                .tint(.green)
            }
            .swipeActions(edge: .trailing) {
                Button("Save") {
                    model.saveCoupon()
                    model.randomizeNextResult()
                }
                .tint(.blue)
            }
            .padding(.all, 10)
            HStack { // add real past result
                ForEach(model.pastResultToAddManually.numbers) { number in
                    SingleNumberInfo(model: model, number: number, showAge: false, isPast: true)
                }
            }
            .swipeActions(edge: .trailing) {
                Button("Save real result") {
                    // TODO: implement me
                    //model.savePastResult()
                }
                .tint(.yellow)
            }
            ForEach(model.data?.results ?? [], id: \.self) { result in
                HStack {
                    ForEach(result.numbers) { number in
                        SingleNumberInfo(model: model, number: number)
                    }
                }
            }
        }
    }
}

#Preview {
    let model = ResultsModel<LottoResult>()
    model.loadResults()
    return ResultsView(model: model)
}
