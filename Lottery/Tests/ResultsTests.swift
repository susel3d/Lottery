//
//  MockDrawResult.swift
//  Lottery
//
//  Created by Łukasz Kmiotek on 16/02/2025.
//

import XCTest
@testable import Lottery

class MockStatisticsHandler<ResultType: DrawResult>: StatisticsHandler<ResultType> {

    override func updatePositionsStatistics(results: [ResultType],
                                            rangeOfIntereset: ResultsRangeOfInterest?) throws -> ResultsStatistic {
        ResultsStatistic(average: [1.0, 2.0, 3.0, 4.0, 5.0], standardDeviation: [1.0, 2.0, 3.0, 4.0, 5.0])
    }
}

class ResultsTests: XCTestCase {

    var mockResults: AgesPerPositionResults<MockDrawResult>!
    var mockStatisticsHandler: MockStatisticsHandler<MockDrawResult>!
    var mockNumbers: [Number]!

    override func setUp() {
        super.setUp()
        mockNumbers = [
            Number(value: 1, age: 10),
            Number(value: 2, age: 20),
            Number(value: 3, age: 30),
            Number(value: 4, age: 40),
            Number(value: 5, age: 42)
        ]
        mockStatisticsHandler = MockStatisticsHandler<MockDrawResult>()
    }

    override func tearDown() {
        mockResults = nil
        mockStatisticsHandler = nil
        mockNumbers = nil
        super.tearDown()
    }

    func testInitializationValid() {
        do {
            mockResults = try AgesPerPositionResults(numbersAgedByLastResult: mockNumbers,
                                      results: [
                                        MockDrawResult(idx: 0,
                                                       numbers: mockNumbers,
                                                       date: .now)
                                      ],
                                      statisticsHandler: mockStatisticsHandler)
            XCTAssertNotNil(mockResults)
        } catch {
            XCTFail("Initialization failed: \(error)")
        }
    }

    func testInitializationWithError() {
        // Simulating a failure case in the initialization
        do {
            mockResults = try AgesPerPositionResults(numbersAgedByLastResult: [],
                                       results: [],
                                       statisticsHandler: mockStatisticsHandler)
            XCTFail("Expected an error to be thrown")
        } catch {
            XCTAssertTrue(error is ResultDataError, "Unexpected error type")
        }
    }

    func testGetNumbers() {
        do {
            mockResults = try AgesPerPositionResults(numbersAgedByLastResult: mockNumbers,
                                      results: [
                                        MockDrawResult(idx: 0,
                                                       numbers: mockNumbers,
                                                       date: .now)
                                      ],
                                      statisticsHandler: mockStatisticsHandler)
            let numbers = mockResults.getNumbers(standardDevFactor: 0.6)
            XCTAssertGreaterThan(numbers.count, 0, "Expected some numbers to be returned")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }

//    func testPrepareCoupon() {
//        do {
//            mockResults = try Results(numbersAgedByLastResult: mockNumbers,
//                                      results: [
//                                        MockDrawResult(idx: 0,
//                                                       numbers: mockNumbers,
//                                                       date: .now)
//                                      ],
//                                      statisticsHandler: mockStatisticsHandler)
//            mockResults.prepareCoupon(couponsCount: 5)
//            XCTAssertTrue(true, "Coupon preparation completed")
//        } catch {
//            XCTFail("Test failed: \(error)")
//        }
//    }

    func testCheckResultComplianceWithStats() {
        do {
            mockResults = try AgesPerPositionResults(numbersAgedByLastResult: mockNumbers,
                                      results: [
                                        MockDrawResult(idx: 0,
                                                       numbers: mockNumbers,
                                                       date: .now)
                                      ],
                                      statisticsHandler: mockStatisticsHandler)
            let roi = ResultsRangeOfInterest(startingIdx: 1, length: 1)
            let comparators = try mockResults.checkResultComplianceWithStats(roi: roi)
            XCTAssertGreaterThan(comparators.count, 0, "Expected at least one comparator result")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }

    func testGetNumbersFullfiling() {
        do {
            mockResults = try AgesPerPositionResults(numbersAgedByLastResult: mockNumbers,
                                      results: [
                                        MockDrawResult(idx: 0,
                                                       numbers: mockNumbers,
                                                       date: .now)
                                      ],
                                      statisticsHandler: mockStatisticsHandler)
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
            mockResults = try AgesPerPositionResults(numbersAgedByLastResult: [],
                                       results: [],
                                       statisticsHandler: mockStatisticsHandler)
            let numbers = mockResults.getNumbers(standardDevFactor: 0.6)
            XCTAssertEqual(numbers.count, 0, "Expected no numbers when results are empty")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }

    func testHighStandardDeviation() {
        do {
            mockResults = try AgesPerPositionResults(numbersAgedByLastResult: mockNumbers,
                                      results: [
                                        MockDrawResult(idx: 0,
                                                       numbers: mockNumbers,
                                                       date: .now)
                                      ],
                                      statisticsHandler: mockStatisticsHandler)
            let numbers = mockResults.getNumbers(standardDevFactor: 10.0)
            XCTAssertGreaterThan(numbers.count, 0, "Expected some numbers to be returned even with high standard deviation")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }

    func testNoNumbersFulfillingStats() {
        // Case where no numbers match the stats
        do {
            mockResults = try AgesPerPositionResults(numbersAgedByLastResult: mockNumbers,
                                      results: [
                                        MockDrawResult(idx: 0,
                                                       numbers: mockNumbers,
                                                       date: .now)
                                      ],
                                      statisticsHandler: mockStatisticsHandler)
            let statistics = ResultsStatistic(average: [100, 200, 300, 400, 500], standardDeviation: [10, 20, 30, 40, 50])
            let result = mockResults.getNumbersFullfiling(statistics: statistics, for: 0, standardDevFactor: 0.6)
            XCTAssertEqual(result.numbers.count, 0, "Expected no numbers fulfilling the stats")
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }
}
