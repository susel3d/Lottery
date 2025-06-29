//
//  AgingHelperTests.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 16/02/2025.
//

import XCTest
@testable import Lottery

class AgingHelperTests: XCTestCase {

    // Test: agedNumbersBasedOn
    func testAgedNumbersBasedOn_withEmptyResults_shouldReturnAllAgedNumbers() {
        let results: [MockDrawResult] = []
        let result = AgingHelper<MockDrawResult>.agedNumbersBasedOn(results)

        XCTAssertEqual(result.count, 42)
        for number in result {
            XCTAssertNil(number.age) // No numbers should have age assigned
        }
    }

    func testAgedNumbersBasedOn_withSingleResult_shouldReturnAgedNumbersWithAge() {
        let numbers = (1...5).map { Number(value: $0) }
        let result = [MockDrawResult(idx: 0, numbers: numbers, date: Date())]

        let agedNumbers = AgingHelper<MockDrawResult>.agedNumbersBasedOn(result)

        XCTAssertEqual(agedNumbers.count, 42)
        for idx in 0..<5 {
            XCTAssertEqual(agedNumbers[idx].age, 0) // Numbers should have age '0'
        }
    }

    func testAgedNumbersBasedOn_withMultipleResults_shouldAgeAllNumbersCorrectly() {
        let results: [MockDrawResult] = [
            MockDrawResult(idx: 0, numbers: [5, 12, 14, 21, 32].map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 1, numbers: [2, 7, 8, 29, 34].map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 2, numbers: [5, 13, 21, 34, 42].map { Number(value: $0) }, date: Date())
        ]

        let agedNumbers = AgingHelper<MockDrawResult>.agedNumbersBasedOn(results)

        XCTAssertEqual(agedNumbers.count, 42)

        XCTAssertEqual(agedNumbers[4].age, 0) // Number 5
        XCTAssertEqual(agedNumbers[11].age, 0) // Number 12
        XCTAssertEqual(agedNumbers[13].age, 0) // Number 14
        XCTAssertEqual(agedNumbers[20].age, 0) // Number 21
        XCTAssertEqual(agedNumbers[31].age, 0) // Number 32

        XCTAssertEqual(agedNumbers[1].age, 1) // Number 2
        XCTAssertEqual(agedNumbers[6].age, 1) // Number 7
        XCTAssertEqual(agedNumbers[7].age, 1) // Number 8
        XCTAssertEqual(agedNumbers[28].age, 1) // Number 29
        XCTAssertEqual(agedNumbers[33].age, 1) // Number 34

        XCTAssertEqual(agedNumbers[4].age, 0) // Number 5       // last result
        XCTAssertEqual(agedNumbers[12].age, 2) // Number 13
        XCTAssertEqual(agedNumbers[20].age, 0) // Number 21     // last result
        XCTAssertEqual(agedNumbers[33].age, 1) // Number 34     // middle result
        XCTAssertEqual(agedNumbers[41].age, 2) // Number 42

    }

    func testAgedNumbersBasedOn_withResultsInRangeOfInterest_shouldAgeNumbersWithinRange() {
        let numbers = (1...5).map { Number(value: $0) }
        let results: [MockDrawResult] = [
            MockDrawResult(idx: 0, numbers: numbers, date: Date()),
            MockDrawResult(idx: 1, numbers: numbers, date: Date()),
            MockDrawResult(idx: 2, numbers: numbers, date: Date())
        ]
        let roi = ResultsRangeOfInterest(startingIdx: 0, length: 0)

        let agedNumbers = AgingHelper<MockDrawResult>.agedNumbersBasedOn(results, roi: roi)

        XCTAssertEqual(agedNumbers.count, 42)
        for idx in 0..<5 {
            // Only the first result should be used, so all numbers will have age 0
            XCTAssertEqual(agedNumbers[idx].age, 0)
        }
    }

    // Test: agedResultsBasedOn
    func testAgedResultsBasedOn_withSingleResult_shouldReturnWithoutAge() {
        let numbers = (1...5).map { Number(value: $0) }
        let result = [MockDrawResult(idx: 0, numbers: numbers, date: Date())]

        guard let agedResults = try? AgingHelper<MockDrawResult>.agedResultsBasedOn(result) else {
            XCTFail("Cannot age results")
            return
        }

        XCTAssertEqual(agedResults.count, 1)
        XCTAssertEqual(agedResults[0].numbers.count, 5)
        for idx in 0..<5 {
            XCTAssertNil(agedResults[0].numbers[idx].age) // No aging should happen
        }
    }

    func testAgedResultsBasedOn_withMultipleResults_shouldReturnAgedResults() {
        let results: [MockDrawResult] = [
            MockDrawResult(idx: 0, numbers: [5, 12, 14, 21, 32].map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 1, numbers: [2, 7, 8, 29, 34].map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 2, numbers: (1...5).map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 3, numbers: (6...10).map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 4, numbers: (11...15).map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 5, numbers: (16...20).map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 6, numbers: (21...25).map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 7, numbers: (26...30).map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 8, numbers: (31...35).map { Number(value: $0) }, date: Date()),
            MockDrawResult(idx: 9, numbers: (36...40).map { Number(value: $0) }, date: Date()),

        ]

        guard let agedResults = try? AgingHelper<MockDrawResult>.agedResultsBasedOn(results) else {
            XCTFail("Cannot age results")
            return
        }

        XCTAssertEqual(agedResults.count, 10)
        XCTAssertEqual(agedResults[0].numbers[0].age, 1) // 5
        XCTAssertEqual(agedResults[0].numbers[1].age, 3) // 12
        XCTAssertEqual(agedResults[0].numbers[2].age, 3) // 14
        XCTAssertEqual(agedResults[0].numbers[3].age, 5) // 21
        XCTAssertEqual(agedResults[0].numbers[4].age, 7) // 32

        XCTAssertEqual(agedResults[1].numbers[0].age, 0) // 2
        XCTAssertEqual(agedResults[1].numbers[1].age, 1) // 7
        XCTAssertEqual(agedResults[1].numbers[2].age, 1) // 8
        XCTAssertEqual(agedResults[1].numbers[3].age, 5) // 29
        XCTAssertEqual(agedResults[1].numbers[4].age, 6) // 34

        agedResultsNumberWithoutAge(indices: Array(2...9))

        func agedResultsNumberWithoutAge(indices: [Int]) {
            for idx in indices {
                for number in agedResults[idx].numbers {
                    XCTAssertNil(number.age)
                }
            }
        }

    }

    func testAgedResultsBasedOn_withNoResults_shouldReturnEmptyArray() {
        let results: [MockDrawResult] = []

        guard let agedResults = try? AgingHelper<MockDrawResult>.agedResultsBasedOn(results) else {
            XCTFail("Cannot age results")
            return
        }

        XCTAssertEqual(agedResults.count, 0)
    }

    func testAgedResultsBasedOn_withMissingNumbers_shouldThrowError() {
        let results: [MockDrawResult] = [
            MockDrawResult(idx: 0, numbers: [Number(value: 1)], date: Date()),
            MockDrawResult(idx: 1, numbers: [Number(value: 2)], date: Date())
        ]

        XCTAssertThrowsError(try AgingHelper<MockDrawResult>.agedResultsBasedOn(results)) { error in
            // then
            XCTAssertEqual(error as? AgingHelperError, .wrongNumbersCount)
        }
    }

}
