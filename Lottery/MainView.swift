//
//  MainView.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 11/03/2024.
//

import SwiftUI
import CoreData

struct MainView: View {

    @ObservedObject var model: ResultsModel

    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: 50))
    ]

    var body: some View {

        NavigationView {
            ScrollView {
                LazyVGrid(columns: adaptiveColumn, spacing: 20) {
                    ForEach(model.numbersWithAge) { number in
                        SingleNumberInfo(model: model, number: number)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ResultsView(model: model)) {
                        Image(systemName: "list.bullet.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CouponView(model: model)) {
                        Image(systemName: "star.circle")
                    }
                }
            }
        }
        .onAppear {
            model.loadResults()
        }
    }
}

#Preview {
    let model = ResultsModel()
    return MainView(model: model)
}
