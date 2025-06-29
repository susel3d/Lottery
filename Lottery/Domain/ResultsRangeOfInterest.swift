//
//  File.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 01/12/2024.
//

import Foundation

struct ResultsRangeOfInterest: CustomDebugStringConvertible {

    let startingIdx: Int
    let length: Int
    var endIdx: Int {
        max(0, startingIdx + length - 1)
    }

    init(startingIdx: Int, length: Int) {
        self.startingIdx = startingIdx
        self.length = length
    }

    func isScopeValidFor(_ results: [any DrawResult]) -> Bool {
        return results.startIndex <= startingIdx && results.endIndex >= endIdx
    }

    var debugDescription: String {
        return "\(startingIdx), \(length)"
    }
}
