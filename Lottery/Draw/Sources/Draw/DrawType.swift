//
//  DrawType.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/01/2026.
//

public enum DrawType {

    case lotto
    case miniLotto

    public var stringKey: String {
        switch self {
        case .lotto:
            "lotto"
        case .miniLotto:
            "miniLotto"
        }
    }

    public var validNumbersCount: Int {
        switch self {
        case .lotto:
            6
        case .miniLotto:
            5
        }
    }

    public var validNumberMaxValue: Int {
        switch self {
        case .lotto:
            49
        case .miniLotto:
            42
        }
    }

    public var sourceFileName: String {
        "\(stringKey).txt"
    }
}
