//
//  CouponListViewModel.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 03/09/2025.
//

import AVFoundation
import Observation

@Observable
class CouponListViewModel {

    let coupons: [[GeneratedCoupon]]
    private let speechManager: SpeechManagerProtocol

    init(coupons: [GeneratedCoupon], speechManager: SpeechManagerProtocol = SpeechManager()) {
        self.coupons = coupons.chunked(into: 10)
        self.speechManager = speechManager
    }

    func speak(coupon: GeneratedCoupon) {
        speechManager.speak(coupon.toString())
    }
}

extension GeneratedCoupon {
    func toString() -> String {
        let stringValues = value.map { String($0) }
        let couponString = stringValues.joined(separator: ", ")
        return couponString
    }
}

protocol SpeechManagerProtocol {
    func speak(_ text: String)
}

private class SpeechManager: SpeechManagerProtocol {

    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

extension Array {

    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
