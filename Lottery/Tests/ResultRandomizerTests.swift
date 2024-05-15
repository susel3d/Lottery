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
        let positionsMeanAge = ResultRandomizer.positionAverageAgeFor(results: results)
        
        // then
        XCTAssertEqual(expectedAges, positionsMeanAge)
    }
    
    func test_randomForPositionAverageAgeNumbersAgeVariation_ReturnNilWhenCannotDeriveRandomResult() {
        // given
        let positionAverage = [3, 7, 12, 20, 22, 29]
        let numbers = Array(1...Result.validNumberMaxValue).map { Number(value: $0, age: 0) }
        
        // when
        let result = ResultRandomizer.randomFor(positionAverageAge: positionAverage, numbers: numbers)
        
        // then
        XCTAssertNil(result)
    }
    
    func test_randomForPositionAverageAgeNumbersAgeVariation_ReturnsValidResult() {
        // given
        let positionAverage = [3, 7, 12, 20, 22, 29]
        var numbers = Array(1...Result.validNumberMaxValue).map { Number(value: $0, age: 0) }
        
        let expected = "6,13,17,21,31,40"
        
        numbers[5].age = 4
        numbers[12].age = 19
        numbers[16].age = 23
        numbers[20].age = 8
        numbers[30].age = 13
        numbers[39].age = 30
        
        // when
        let result = ResultRandomizer.randomFor(positionAverageAge: positionAverage, numbers: numbers)
        
        // then
        XCTAssertNotNil(result)
        XCTAssert(result?.numbers.count == Result.validNumbersCount)
        XCTAssertEqual(expected, result!.numbersAsString())
    }
}
