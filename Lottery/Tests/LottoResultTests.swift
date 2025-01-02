//
//  ResultTests.swift
//  LotteryTests
//
//  Created by Lukasz Kmiotek on 25/03/2024.
//

import XCTest
@testable import Lottery

final class LottoResultTests: XCTestCase {

    func test_NumbersFromString_StringWithoutNumbers() {
        let string = "There isn't any number."
        XCTAssertThrowsError(try LottoResult.numbersFromString(string)) { error in
            XCTAssertEqual(error as? ResultError, .wrongNumbersCount)
        }
    }

    func test_NumbersFromString_StringWithTooFewNumbers() {
        let string = "1,2,3"
        XCTAssertThrowsError(try LottoResult.numbersFromString(string)) { error in
            XCTAssertEqual(error as? ResultError, .wrongNumbersCount)
        }
    }

    func test_NumbersFromString_StringWithTooManyNumbers() {
        let string = "1,2,3,4,5,6,7,8,9,10"
        XCTAssertThrowsError(try LottoResult.numbersFromString(string)) { error in
            XCTAssertEqual(error as? ResultError, .wrongNumbersCount)
        }
    }

    func test_NumbersFromString_StringWithNumbersInvalidRange() {
        let string = "111,-12,13,14,15,160"
        XCTAssertThrowsError(try LottoResult.numbersFromString(string)) { error in
            XCTAssertEqual(error as? ResultError, .wrongNumbersRange)
        }
    }

    func test_NumbersFromString_CorrectString() {
        // given
        let string = "11,12,13,14,15,16"
        let expected = [11, 12, 13, 14, 15, 16]
        // when
        if let result = try? LottoResult.numbersFromString(string) {
            // then
            XCTAssertEqual(expected, result.map {$0.value})
        } else {
            XCTFail("Cannot convert numbers from string")
        }
    }

    func test_ResultsFromLines_CorrectLine() {
        // given
        let line = "7015. 19.03.2024 4,12,31,39,41,48"
        // when
        if let result = try? LottoResult.resultsFrom(lines: [line]) {
            // then
            XCTAssertEqual(result.count, 1)
            XCTAssertEqual(result[0].idx, 7015)
            XCTAssertEqual(result[0].numbers.map {$0.value}, [4, 12, 31, 39, 41, 48])
        } else {
            XCTFail("Cannot convert line")
        }
    }

    func test_ResultsFromLines_EmptyLine() {
        // given
        let line = ""
        // when
        XCTAssertThrowsError(try LottoResult.resultsFrom(lines: [line])) { error in
            // then
            XCTAssertEqual(error as? DataParsingError, .emptyLine)
        }
    }

    func test_ResultsFromLines_MissingComponent() {
        // given
        let line = "7015. 4,12,31,39,41,48"
        // when
        XCTAssertThrowsError(try LottoResult.resultsFrom(lines: [line])) { error in
            // then
            XCTAssertEqual(error as? DataParsingError, .missingComponent)
        }
    }

    func test_ResultsFromLines_WrongComponent() {
        // given
        let line = "7015. 2024.03.19 4,12,31,39,41,48"
        // when
        XCTAssertThrowsError(try LottoResult.resultsFrom(lines: [line])) { error in
            // then
            XCTAssertEqual(error as? DataParsingError, .wrongComponent)
        }
    }

    func test_ResultsFromLines_WrongNumbersCount() {
        // given
        let line = "7015. 19.03.2024 4,12,31,39"
        // when
        XCTAssertThrowsError(try LottoResult.resultsFrom(lines: [line])) { error in
            // then
            XCTAssertEqual(error as? DataParsingError, .wrongNumbersCount)
        }
    }

}
