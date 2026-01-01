//
//  DrawType.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/01/2026.
//

enum DrawType {

    case lotto
    case miniLotto

    var stringKey: String {
        switch self {
        case .lotto:
            "lotto"
        case .miniLotto:
            "miniLotto"
        }
    }

    var validNumbersCount: Int {
        switch self {
        case .lotto:
            6
        case .miniLotto:
            5
        }
    }

    var validNumberMaxValue: Int {
        switch self {
        case .lotto:
            49
        case .miniLotto:
            42
        }
    }

    var sourceFileName: String {
        "\(stringKey).txt"
    }
}
