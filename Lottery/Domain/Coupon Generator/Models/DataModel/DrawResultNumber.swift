//
//  DrawResultNumber.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/01/2026.
//


struct DrawResultNumber: Number, Comparable {

    static func < (lhs: DrawResultNumber, rhs: DrawResultNumber) -> Bool {
        lhs.value < rhs.value
    }

    let value: Int

    static func empty() -> DrawResultNumber {
        DrawResultNumber(value: 0)
    }
}