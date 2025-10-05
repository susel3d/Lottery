//
//  MainView.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 04/10/2025.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink(destination: CouponsGeneratorView(
                    viewModel: resolveDI(CouponsGeneratorViewModel.self)
                )) {
                    Text("Coupon Generator")
                        .mainViewTextStyle()
                }
                NavigationLink(destination: TuneModelsView()) {
                    Text("Tune Models")
                        .mainViewTextStyle()
                }
            }
            .padding()
        }
    }
}

private struct MainViewTextStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(20)
    }
}

private extension Text {
    func mainViewTextStyle() -> some View {
        self.modifier(MainViewTextStyleModifier.init())
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
