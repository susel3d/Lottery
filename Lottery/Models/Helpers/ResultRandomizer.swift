//
//  ResultRandomizer.swift
//  Lottery
//
//  Created by Lukasz.Kmiotek on 2024-05-13.
//

import Foundation

class ResultRandomizer {
    
    private init() {
        
    }
    
    static func positionAverageAgeFor(results: [Result]) -> [Int] {
        var positionsMeanAge = Array(repeating: Int(0), count: Result.validNumbersCount)
        
        for result in results {
            let sortedAges = result.numbers.compactMap({$0.age}).sorted(by: <)
            positionsMeanAge = zip(positionsMeanAge, sortedAges).map(+)
        }
        positionsMeanAge = positionsMeanAge.map { Int($0/results.count) }
        return positionsMeanAge
    }
    
    static func randomFor(positionAverageAge: [Int], numbers: [Number], ageVariation: Int = 2) -> Result? {
        var futureNumbers: [Number] = []
        
        for positionAge in positionAverageAge {
            let bottomAge = positionAge - ageVariation
            let topAge = positionAge + ageVariation
            let almostSameAge = numbers.filter { $0.age! >= bottomAge && $0.age! <= topAge }
            if almostSameAge.isEmpty {
                return nil
            }
            var randomNumber: Number?
            
            repeat {
                randomNumber = almostSameAge.randomElement()
            } while futureNumbers.contains { $0.value == randomNumber?.value ?? -1 }
            
            if let randomNumber {
                futureNumbers.append(randomNumber)
            }
        }
        
        let result = Result(idx: 0, date: .now, numbers: futureNumbers.sorted(by: <))
        return result
    }
    
    static func randomFor(results: [Result], numbers: [Number], ageVariation: Int = 2) -> Result? {
        let positionAverageAge = positionAverageAgeFor(results: results)
        let result = randomFor(positionAverageAge: positionAverageAge, numbers: numbers)
        return result
    }
}
