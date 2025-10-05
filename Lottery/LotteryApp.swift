//
//  LotteryApp.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 11/03/2024.
//

import SwiftUI

@main
struct LotteryApp: App {

    let diContainer = DependencyInjection()
    let stateStore = StateStore()

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
