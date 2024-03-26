//
//  ResultsView.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 12/03/2024.
//

import SwiftUI

struct ResultsView: View {

    @ObservedObject var model: ResultsModel

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
                    model.savePastResult()
                }
                .tint(.yellow)
            }
            ForEach(model.resultsWithAge, id: \.self) { result in
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
    let model = ResultsModel()
    model.loadResults()
    return ResultsView(model: model)
}
