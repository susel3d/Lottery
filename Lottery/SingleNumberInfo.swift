//
//  SingleNumberInfo.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 12/03/2024.
//

import SwiftUI

struct SingleNumberInfo: View {

    @ObservedObject var model: ResultsModel

    var number: Number?
    var showAge = true
    var isFuture = false
    var isPast = false

    func displayNumber() -> Number {
        number ?? Number(value: 0)
    }

    var body: some View {
        VStack {
            ValueView(model: model, number: displayNumber(), isFuture: isFuture, isPast: isPast)
            if showAge {
                AgeView(number: displayNumber(), isFuture: isFuture)
            }
        }
    }
}

#Preview {
    let model = ResultsModel()
    return SingleNumberInfo(model: model)
}

struct AgeView: View {

    var number: Number
    var isFuture = false

    private func greenHue() -> UIColor {
        let greenValue = max(0.9-(0.02*CGFloat(number.age ?? 0)), 0.5)
        return UIColor(red: 0, green: greenValue, blue: 0, alpha: 1.0)
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(uiColor: greenHue()))
                .frame(height: 40)
            Label(
                title: { Text("\(number.age ?? 0)") },
                icon: {  }
            )
            .foregroundStyle(.black)
        }
        .onTapGesture {
            if isFuture {
                print("Set age conditions")
            }
        }
    }
}

struct ValueView: View {

    @ObservedObject var model: ResultsModel

    @State var number: Number
    var isFuture = false
    var isPast = false

    @State private var showPastNumberInput = false
    @State private var pastNumberCandidate = ""

    var body: some View {
        ZStack {
            Circle()
                .fill(.yellow)
                .strokeBorder(.blue, lineWidth: isFuture ? 1 : 0)
                .frame(height: 40)
            Label(
                title: { Text("\(number.value)") },
                icon: {  }
            ).foregroundStyle(.black)
        }
        .alert("Past real result", isPresented: $showPastNumberInput) {
            TextField("", text: $pastNumberCandidate)
                .keyboardType(.numberPad)
            Button("OK", action: updatePastNumber)
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Please enter past result")
        }
        .onTapGesture {
            if isFuture {
                print("Randomize this number!")
            }
            if isPast {
                showPastNumberInput = true
            }
        }
    }

    func updatePastNumber() {
        guard let num = Int(pastNumberCandidate), num <= Result.validNumberMaxValue && num > 0 else {
            pastNumberCandidate = ""
            return
        }
        if !model.pastResultToAddManually.containsNumber(num) {
            if let idx = model.pastResultToAddManually.numbers.firstIndex(where: {$0.id == number.id}) {
                model.pastResultToAddManually.numbers.remove(at: idx)
                number = Number(id: number.id, value: num)
                model.pastResultToAddManually.numbers.insert(number, at: idx)
            }
        }

    }
}
