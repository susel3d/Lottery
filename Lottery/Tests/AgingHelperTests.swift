//
//  AgingHelperTests.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 16/02/2025.
//

import XCTest
@testable import Lottery

class AgingHelperTests: XCTestCase {

    func testAgedNumbersBasedOn_withEmptyResults_shouldReturnAllAgedNumbers() {
        let results: [MockDrawResult] = []
        let result = AgingHelper.agedNumbersBasedOn(results, drawType: .miniLotto)

        XCTAssertEqual(result.count, 42)
        for number in result {
            XCTAssertNil(number.age) // No numbers should have age assigned
        }
    }

    func testAgedNumbersBasedOn_withSingleResult_shouldReturnAgedNumbersWithAge() {
        let numbers = (1...5).map { AgedNumber(value: $0) }
        let result = [MockDrawResult(idx: 0, numbers: numbers, date: Date())]

        let agedNumbers = AgingHelper.agedNumbersBasedOn(result, drawType: .miniLotto)

        XCTAssertEqual(agedNumbers.count, 42)
        for idx in 0..<5 {
            XCTAssertEqual(agedNumbers[idx].age, 0) // Numbers should have age '0'
        }
    }

    func testAgedNumbersBasedOn_withMultipleResults_shouldAgeAllNumbersCorrectly() {
        let results: [MockDrawResult] = [
            MockDrawResult(idx: 0, numbers: [5, 12, 14, 21, 32].map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 1, numbers: [2, 7, 8, 29, 35].map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 2, numbers: [5, 13, 21, 34, 42].map { AgedNumber(value: $0) }, date: Date())
        ]

        let agedNumbers = AgingHelper.agedNumbersBasedOn(results, drawType: .miniLotto)

        XCTAssertEqual(agedNumbers.count, 42)

        XCTAssertEqual(agedNumbers[41].age, 0)
        XCTAssertEqual(agedNumbers[33].age, 0)
        XCTAssertEqual(agedNumbers[20].age, 0)
        XCTAssertEqual(agedNumbers[12].age, 0)
        XCTAssertEqual(agedNumbers[4].age, 0)

        XCTAssertEqual(agedNumbers[1].age, 1)
        XCTAssertEqual(agedNumbers[6].age, 1)
        XCTAssertEqual(agedNumbers[7].age, 1)
        XCTAssertEqual(agedNumbers[28].age, 1)
        XCTAssertEqual(agedNumbers[34].age, 1)

        XCTAssertEqual(agedNumbers[4].age, 0)
        XCTAssertEqual(agedNumbers[7].age, 1)
        XCTAssertEqual(agedNumbers[13].age, 2)
        XCTAssertEqual(agedNumbers[20].age, 0)
        XCTAssertEqual(agedNumbers[31].age, 2)

    }

    func testAgedNumbersBasedOn_withResultsInRangeOfInterest_shouldAgeNumbersWithinRange() {
        let numbers = (1...5).map { AgedNumber(value: $0) }
        let results: [MockDrawResult] = [
            MockDrawResult(idx: 0, numbers: numbers, date: Date()),
            MockDrawResult(idx: 1, numbers: numbers, date: Date()),
            MockDrawResult(idx: 2, numbers: numbers, date: Date())
        ]

        let agedNumbers = AgingHelper.agedNumbersBasedOn(results, drawType: .miniLotto)

        XCTAssertEqual(agedNumbers.count, 42)
        for idx in 0..<5 {
            // Only the first result should be used, so all numbers will have age 0
            XCTAssertEqual(agedNumbers[idx].age, 0)
        }
    }

    func testAgedResultsBasedOn_withMultipleResults_shouldReturnAgedResults() {
        let results: [MockDrawResult] = [
            MockDrawResult(idx: 2, numbers: (1...5).map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 3, numbers: (6...10).map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 4, numbers: (11...15).map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 5, numbers: (16...20).map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 6, numbers: (21...25).map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 7, numbers: (26...30).map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 8, numbers: (31...35).map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 9, numbers: (36...40).map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 10, numbers: [5, 12, 14, 21, 32].map { AgedNumber(value: $0) }, date: Date()),
            MockDrawResult(idx: 11, numbers: [2, 7, 8, 29, 34].map { AgedNumber(value: $0) }, date: Date())
        ]

        guard let agedResults = try? AgingHelper.agedResultsBasedOn(results, drawType: .miniLotto) else {
            XCTFail("Cannot age results")
            return
        }

        XCTAssertEqual(agedResults.count, 2)

        guard let agedNumbers0 = agedResults[0].numbers as? [AgedNumber],
              let agedNumbers1 = agedResults[1].numbers as? [AgedNumber] else {
            XCTFail("Cannot get aged results")
            return
        }

        XCTAssertEqual(agedNumbers0[0].age, 2)
        XCTAssertEqual(agedNumbers0[1].age, 4)
        XCTAssertEqual(agedNumbers0[2].age, 6)
        XCTAssertEqual(agedNumbers0[3].age, 6)
        XCTAssertEqual(agedNumbers0[4].age, 8)

        XCTAssertEqual(agedNumbers1[0].age, 3)
        XCTAssertEqual(agedNumbers1[1].age, 4)
        XCTAssertEqual(agedNumbers1[2].age, 8)
        XCTAssertEqual(agedNumbers1[3].age, 8)
        XCTAssertEqual(agedNumbers1[4].age, 9)
    }

    func testAgedResultsBasedOn_withNoResults_shouldReturnEmptyArray() {
        let results: [MockDrawResult] = []

        guard let agedResults = try? AgingHelper.agedResultsBasedOn(results, drawType: .miniLotto) else {
            XCTFail("Cannot age results")
            return
        }

        XCTAssertEqual(agedResults.count, 0)
    }

    func testAgedResultsBasedOn_withMissingNumbers_shouldThrowError() {
        let results: [MockDrawResult] = [
            MockDrawResult(idx: 0, numbers: [AgedNumber(value: 1)], date: Date()),
            MockDrawResult(idx: 1, numbers: [AgedNumber(value: 2)], date: Date())
        ]

        XCTAssertThrowsError(try AgingHelper.agedResultsBasedOn(results, drawType: .miniLotto)) { error in
            // then
            XCTAssertEqual(error as? AgingHelperError, .wrongNumbersCount)
        }
    }

}
