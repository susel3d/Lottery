//
//  CouponsGeneratorProgresView.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 03/09/2025.
//

import SwiftUI

struct CouponsGeneratorProgresView: View {

    @Binding var progress: Progress
    let stopGeneration: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                progressCircle
                    .frame(width: 150, height: 150)

                Text("Generating Coupons...")
                    .font(.headline)

                Button("Cancel") {
                    stopGeneration()
                }
                .cancelButtonStyle()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }

    @ViewBuilder
    var progressCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.1), lineWidth: 15)
            Circle()
                .stroke(progress.circleColor.opacity(progress.opacityValue), lineWidth: 15)
            Text(progress.description)
                .font(.system(size: 28, weight: .semibold))
        }
    }
}

struct CancelButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

extension Button {
    func cancelButtonStyle() -> some View {
        self.modifier(CancelButtonStyle())
    }
}

#Preview {
    @Previewable @State var progress: Progress = .progress(0.9)
    CouponsGeneratorProgresView(progress: $progress, stopGeneration: { })
}

extension Progress {

    var opacityValue: Double {
        switch self {
        case .progress(let value):
            value
        case .timeout:
            1.0
        }
    }

    var description: String {
        switch self {
        case .progress(let value):
            "\(Int(value * 100))%"
        case .timeout:
            "Timeout!"
        }
    }

    var circleColor: Color {
        switch self {
        case .progress:
            Color.green
        case .timeout:
            Color.red
        }
    }
}
