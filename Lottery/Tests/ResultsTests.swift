//
//  MockDrawResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 16/02/2025.
//

import XCTest
@testable import Lottery

class MockStatisticsHandler: StatisticsHandler {

    override static func updateAgeStatistics(
        results: [DrawResult],
        rangeOfIntereset: ResultsRangeOfInterest?,
        validNumbersCount: Int) throws -> ResultsStatistic {
            ResultsStatistic(average: [1.0, 2.0, 3.0, 4.0, 5.0], standardDeviation: [1.0, 2.0, 3.0, 4.0, 5.0])
    }
}

class ResultsTests: XCTestCase {

    var mockResults: AgesPerPositionResults!
    var mockStatisticsHandler: MockStatisticsHandler!
    var mockNumbers: [AgedNumber]!

    override func setUp() {
        super.setUp()
        mockNumbers = [
            AgedNumber(value: 1, age: 10),
            AgedNumber(value: 2, age: 20),
            AgedNumber(value: 3, age: 30),
            AgedNumber(value: 4, age: 40),
            AgedNumber(value: 5, age: 42)
        ]
        mockStatisticsHandler = MockStatisticsHandler()
    }

    override func tearDown() {
        mockResults = nil
        mockStatisticsHandler = nil
        mockNumbers = nil
        super.tearDown()
    }

    func testInitializationValid() {
        do {
            mockResults = try AgesPerPositionResults(
                numbersAgedByLastResult: mockNumbers,
                results: [
                    MockDrawResult(idx: 0,
                                   numbers: mockNumbers,
                                   date: .now)
                ],
                rangeOfIntereset: ResultsRangeOfInterest(startingIdx: 0, length: 1),
                validNumbersCount: DrawType.miniLotto.validNumbersCount
            )
            XCTAssertNotNil(mockResults)
        } catch {
            XCTFail("Initialization failed: \(error)")
        }
    }

    func testGetNumbers() {
        do {
            mockResults = try AgesPerPositionResults(
                numbersAgedByLastResult: mockNumbers,
                results: [
                    MockDrawResult(idx: 0,
                                   numbers: mockNumbers,
                                   date: .now)
                ],
                rangeOfIntereset: ResultsRangeOfInterest(startingIdx: 0, length: 1),
                validNumbersCount: DrawType.miniLotto.validNumbersCount
            )
            let numbers = mockResults.getNumbers(standardDevFactor: 0.6)
            XCTAssertGreaterThan(numbers.count, 0, "Expected some numbers to be returned")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }

    func testGetNumbersFullfiling() {
        do {
            mockResults = try AgesPerPositionResults(
                numbersAgedByLastResult: mockNumbers,
                results: [
                    MockDrawResult(idx: 0,
                                   numbers: mockNumbers,
                                   date: .now)
                ],
                rangeOfIntereset: ResultsRangeOfInterest(startingIdx: 0, length: 1),
                validNumbersCount: DrawType.miniLotto.validNumbersCount
            )
            let statistics = ResultsStatistic(average: [10, 20, 30, 40, 50], standardDeviation: [1, 1, 1, 1, 1])
            let result = mockResults.getNumbersFullfiling(statistics: statistics, for: 0, standardDevFactor: 0.6)
            XCTAssertGreaterThan(result.numbers.count, 0, "Expected numbers fulfilling the stats")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }

    // Edge Case Tests
    func testEmptyResults() {
        do {
            mockResults = try AgesPerPositionResults(
                numbersAgedByLastResult: [],
                results: [],
                rangeOfIntereset: ResultsRangeOfInterest(startingIdx: 0, length: 1),
                validNumbersCount: DrawType.miniLotto.validNumbersCount
            )
            XCTFail("Expected an error to be thrown")
        } catch ResultDataError.emptyResults {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }

    func testHighStandardDeviation() {
        do {
            mockResults = try AgesPerPositionResults(
                numbersAgedByLastResult: mockNumbers,
                results: [
                    MockDrawResult(idx: 0,
                                   numbers: mockNumbers,
                                   date: .now)
                ],
                rangeOfIntereset: ResultsRangeOfInterest(startingIdx: 0, length: 1),
                validNumbersCount: DrawType.miniLotto.validNumbersCount
            )
            let numbers = mockResults.getNumbers(standardDevFactor: 10.0)
            XCTAssertGreaterThan(numbers.count, 0, "Expected some numbers even with high standard deviation")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }

    func testNoNumbersFulfillingStats() {
        // Case where no numbers match the stats
        do {
            mockResults = try AgesPerPositionResults(
                numbersAgedByLastResult: mockNumbers,
                results: [
                    MockDrawResult(idx: 0,
                                   numbers: mockNumbers,
                                   date: .now)
                ],
                rangeOfIntereset: ResultsRangeOfInterest(startingIdx: 0, length: 1),
                validNumbersCount: DrawType.miniLotto.validNumbersCount
            )
            let statistics = ResultsStatistic(
                average: [100, 200, 300, 400, 500],
                standardDeviation: [10, 20, 30, 40, 50]
            )
            let result = mockResults.getNumbersFullfiling(statistics: statistics, for: 0, standardDevFactor: 0.6)
            XCTAssertEqual(result.numbers.count, 0, "Expected no numbers fulfilling the stats")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }
}
