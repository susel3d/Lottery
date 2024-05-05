//
//  DataModelTests.swift
//  LotteryTests
//
//  Created by Lukasz Kmiotek on 2024-05-05.
//

import XCTest
import Combine
@testable import Lottery

final class DataModelTests: XCTestCase {

    private var subscriptions = Set<AnyCancellable>()
    
    override func tearDown() {
        DataModel.shared.clearPastResults()
        subscriptions.removeAll()
    }
    
    func test_loadData_ifPastResultsArePopulated() {
        
        // given
        let sut = DataModel.shared
        let expectation = XCTestExpectation(description: "Past results are populated")
        
        sut.pastResults.sink { results in
            if !results.isEmpty {
                expectation.fulfill()
            }
        }.store(in: &subscriptions)
        
        // when
        sut.loadData()
        
        // then
        wait(for: [expectation], timeout: 2)
    }

    func test_savePastResult_PastResultsGetUpdated() {
        
        // given
        let sut = DataModel.shared
        let numbers = [2, 13, 17, 23, 28, 31]
        let mappedNumbers = numbers.map { Number(value: $0) }
        var result = Result(idx: 7, date: .now, numbers: mappedNumbers)
        let numbersAsStrings = result.numbersAsString()
        let expectation = XCTestExpectation(description: "Past results are updated with new entry")
        
        sut.pastResults.sink { results in
            if numbersAsStrings == results.first?.numbersAsString() {
                expectation.fulfill()
            }
        }.store(in: &subscriptions)
        
        // when
        sut.loadData()
        sut.savePastResult(&result)
        
        // then
        wait(for: [expectation], timeout: 2)
    }
}
