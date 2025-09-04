//
//  ResultsDataTests.swift
//  LotteryTests
//
//  Created by Łukasz Kmiotek on 10/10/2024.
//

//import XCTest
//@testable import Lottery
//
//final class ResultsStatisticTests: XCTestCase {
//
//    func test_updatePositionsStatistics_RangeOfInterestNotDefined_Statistics_Not_Derived() throws {
//
//        let sut = try prepareSUT()
//
//        XCTAssertNil(sut.positionStatistics)
//    }
//
//    func test_updatePositionsStatistics_RangeOfInterestDefined_StatisticsDerived() throws {
//
//        let numbers = testNumbers()
//        let result = LottoDrawResult(idx: 0, date: .now, numbers: numbers)
//        let rangeOfInterest = ResultsRangeOfInterest(startingIdx: 0, length: 1)
//        let sut = try prepareSUT(numbers: numbers, results: [result], rangeOfInterest: rangeOfInterest)
//
//        XCTAssertNotNil(sut.positionStatistics)
//    }
//
//    func test_updatePositionsStatistics_WrongRangeOfInterest_ErrorIsThrown() throws {
//
//        let rangeOfInterest = ResultsRangeOfInterest(startingIdx: 0, length: 100)
//
//        XCTAssertThrowsError(try prepareSUT(rangeOfInterest: rangeOfInterest)) { error in
//            XCTAssertEqual(error as? ResultDataError, .wrongRangeOfInterestScope)
//        }
//    }
//
//    func test_updatePositionsStatistics_SingleResult_CorrectStatistics() throws {
//
//        let numbers = testNumbers()
//        let result = LottoDrawResult(idx: 0, date: .now, numbers: numbers)
//        let rangeOfInterest = ResultsRangeOfInterest(startingIdx: 0, length: 1)
//        let sut = try prepareSUT(numbers: numbers, results: [result], rangeOfInterest: rangeOfInterest)
//
//        XCTAssertNotNil(sut.positionStatistics)
//        XCTAssertEqual(sut.positionStatistics?.average, ResultsStatisticTests.testData1.map {Double($0.age)})
//        XCTAssertEqual(0, sut.positionStatistics?.standardDeviation.reduce(0, +))
//    }
//
//    func test_updatePositionsStatistics_TwoResults_CorrectStatistics() throws {
//
//        let numbers = [
//            testNumbers(ResultsStatisticTests.testData1),
//            testNumbers(ResultsStatisticTests.testData2)
//        ]
//        let results = [
//            LottoDrawResult(idx: 0, date: .now, numbers: numbers[0]),
//            LottoDrawResult(idx: 1, date: .now, numbers: numbers[1])
//        ]
//        let rangeOfInterest = ResultsRangeOfInterest(startingIdx: 0, length: 2)
//        let sut = try prepareSUT(numbers: numbers[0] + numbers[1], results: results, rangeOfInterest: rangeOfInterest)
//
//        XCTAssertNotNil(sut.positionStatistics)
//        let test1Ages = ResultsStatisticTests.testData1.map { Double($0.age) }
//        let test2Ages = ResultsStatisticTests.testData2.map { Double($0.age) }
//        let testAges = zip(test1Ages, test2Ages).map { ($0 + $1) / 2}
//        XCTAssertEqual(sut.positionStatistics?.average, testAges)
//        XCTAssertEqual(sut.positionStatistics?.standardDeviation, [1, 3, 3, 1, 1, 2])
//    }
//
//    func test_updatePositionsStatistics_LotResults_CorrectOffset() throws {
//
//        var results: [LottoDrawResult] = []
//        var allNumbers: [Number] = []
//        for idx in 0...7 {
//            let age = if idx == 5 { 10 } else if idx == 6 { 8 } else { 0 }
//            let numberData: [NumberData] = Array(1...6).map { ($0 + (6 * idx), age) }
//            let numbers = testNumbers(numberData)
//            allNumbers += numbers
//            let result = LottoDrawResult(idx: idx, date: .now, numbers: numbers)
//            results.append(result)
//        }
//
//        let rangeOfInterest = ResultsRangeOfInterest(startingIdx: 5, length: 2)
//        let sut = try prepareSUT(numbers: allNumbers,
//                                 results: results,
//                                 rangeOfInterest: rangeOfInterest)
//
//        XCTAssertNotNil(sut.positionStatistics)
//        XCTAssertEqual(sut.positionStatistics?.average, Array(repeating: 9.0, count: 6))
//        XCTAssertEqual(sut.positionStatistics?.standardDeviation, Array(repeating: 1.0, count: 6))
//    }
//
//    private func prepareSUT(numbers: [Number] = [],
//                            results: [LottoDrawResult] = [],
//                            rangeOfInterest: ResultsRangeOfInterest? = nil) throws -> AgesPerPositionResults<LottoDrawResult> {
//        let statisticsHandler = StatisticsHandler<LottoDrawResult>()
//        return try AgesPerPositionResults(
//            numbersAgedByLastResult: numbers,
//            results: results,
//            rangeOfIntereset: rangeOfInterest,
//            statisticsHandler: statisticsHandler)
//    }
//
//    private typealias NumberData = (value: Int, age: Int)
//
//    private func testNumbers(_ data: [NumberData] = testData1) -> [Number] {
//        guard data.count == LottoDrawResult.validNumbersCount else {
//            return []
//        }
//        return data.map { Number(value: $0.value, age: $0.age) }
//    }
//
//    private static let testData1: [NumberData] = [(1, 1),
//                                                 (2, 5),
//                                                 (3, 7),
//                                                 (4, 12),
//                                                 (5, 16),
//                                                 (6, 21)]
//
//    private static let testData2: [NumberData] = [(21, 3),
//                                                 (22, 11),
//                                                 (23, 13),
//                                                 (24, 14),
//                                                 (25, 18),
//                                                 (26, 25)]
//}
