//
//  LotteryApp.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 11/03/2024.
//

import SwiftUI

@main
struct LotteryApp: App {

    let model = DataModel.shared

    var body: some Scene {
        WindowGroup {
            MainView(model: ResultsModel())
        }
    }
}
