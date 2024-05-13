//
//  ResultRandomizerTests.swift
//  LotteryTests
//
//  Created by Lukasz.Kmiotek on 2024-05-13.
//

import XCTest
@testable import Lottery

final class ResultRandomizerTests: XCTestCase {

    func test_meanPositionsAgeFor() {
        // given
        let lines = [
            [1, 2, 3, 4, 5, 6],
            [7, 8, 9, 10, 11, 12],
            [13, 14, 15, 16, 17, 18]
        ]
        let expectedAges = Array(0...5).map { linesSumAt(idx: $0) }
        
        func linesSumAt(idx: Int, multiplier: Int = 2) -> Int {
            var result = 0
            for line in lines {
                guard line.count > idx else {
                    return 0
                }
                result += multiplier * line[idx]
            }
            return result/lines.count
        }
        
        let results = [
            Result(idx: 1, date: .now, numbers: lines[0].map { Number(value: $0, age:2*$0) }),
            Result(idx: 2, date: .now, numbers: lines[1].map { Number(value: $0, age:2*$0) }),
            Result(idx: 3, date: .now, numbers: lines[2].map { Number(value: $0, age:2*$0) })
        ]
        // when
        let positionsMeanAge = ResultRandomizer.meanPositionsAgeFor(results: results)
        
        // then
        XCTAssertEqual(expectedAges, positionsMeanAge)
    }

}
