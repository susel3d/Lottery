//
//  Model.swift
//  Lottery
//
//  Created by Lukasz Kmiotek on 11/03/2024.
//

import Foundation
import Combine
import CoreData

class DataModel: ObservableObject {

    var pastResults = CurrentValueSubject<[Result], Never>([])
    var savedCoupons = CurrentValueSubject<[Result], Never>([])

    static let shared = DataModel()

    private let persistenceController = PersistenceController.shared
    private let context = PersistenceController.shared.container.viewContext
    private var subscriptions = Set<AnyCancellable>()

    private init() {
        context.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.overwriteMergePolicyType)
    }

    func loadData() {
        loadPastResultsFromDB()
        if pastResults.value.isEmpty {
            getData()
        }
    }

    func savePastResult(_ result: inout Result) {
        guard let idx = pastResults.value.first?.idx else {
            return
        }
        result.idx = idx + 1
        result.numbers.sort(by: <)
        savePastResultsToDB([result])
        loadPastResultsFromDB()
        result = .empty()
    }

    private func getData() {

        let isPreviewData = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

        let useFile = true || isPreviewData

        if useFile {
            fetchDataFromFile()
        } else {
            fetchDataFromServer()
        }
    }

}

// MARK: Fetching data from server or file

extension DataModel {

    private func fetchDataFromFile() {

        Bundle.main.url(forResource: "lottery.txt", withExtension: nil).publisher
            .tryMap { string in
                try Data(contentsOf: string)
            }.processDataStream()
            .tryMap { try Result.resultsFrom(lines: $0) }
            .sink { _ in
            } receiveValue: { results in
                self.savePastResultsToDB(results)
                self.loadPastResultsFromDB()
            }
            .store(in: &subscriptions)
    }

    private func fetchDataFromServer() {

        let url = URL(string: "")!

        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: RunLoop.main)
            .tryMap { data, _ in data}
            .processDataStream()
            .tryMap { try Result.resultsFrom(lines: $0) }
            .sink { _ in
            } receiveValue: { results in
                self.savePastResultsToDB(results)
                self.loadPastResultsFromDB()
            }
            .store(in: &subscriptions)
    }
}

// MARK: CoreData

extension DataModel {
    
    private func loadPastResultsFromDB() {
        
        let request = PastResults.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "idx", ascending: false)]
        request.fetchLimit = 200
        
        var results: [Result] = []
        
        do {
            let pastResults = try context.fetch(request)
            for pastResult in pastResults {
                let result = Result(idx: Int(pastResult.idx),
                                    date: pastResult.date ?? .now,
                                    numbers: try Result.numbersFromString(pastResult.numbers!))
                results.append(result)
            }
        } catch {
            print(error)
        }
        self.pastResults.send(results)
    }
    
    private func savePastResultsToDB(_ results: [Result]) {
        
        for result in results {
            let pastResult = PastResults(context: context)
            pastResult.idx = Int32(result.idx)
            pastResult.date = result.date
            pastResult.numbers = result.numbersAsString()
        }
        if context.hasChanges {
            try? context.save()
        }
    }
    
    private func clearDBForEntityName(_ entityName: String) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let batchRequest = NSBatchDeleteRequest(fetchRequest: request)
        batchRequest.resultType = .resultTypeObjectIDs

        do {
            _ = try context.execute(batchRequest)
        } catch {
            print(error)
        }
    }

    func clearPastResults() {
        clearDBForEntityName("PastResults")
    }

    func clearSavedCoupons() {
        clearDBForEntityName("Coupon")
    }

    func clearSavedCoupon(_ couponIdx: Int) {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Coupon")
        request.predicate = NSPredicate(format: "idx == %d", couponIdx)

        do {
            if let coupon = try context.fetch(request).first as? NSManagedObject {
                context.delete(coupon)
                try? context.save()
            }
        } catch {
            print(error)
        }
    }

    func saveCoupon(idx: Int, numbers: String) {

        let coupon = Coupon(context: context)

        coupon.numbers = numbers
        coupon.idx = Int32(idx)

        if context.hasChanges {
            try? context.save()
        }
    }

    func loadCoupons() {

        // TODO: Shouldn't be hidden here - move info about mocked data to Preview code
        let isPreviewData = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        if isPreviewData {
            let numbers = [3, 11, 23, 27, 34, 41].map {Number(value: $0)}
            savedCoupons.send([Result(idx: 0, date: .now, numbers: numbers)])
            return
        }

        let request = Coupon.fetchRequest()
        request.fetchLimit = 3

        var results: [Result] = []

        do {
            let coupons = try context.fetch(request)
            for coupon in coupons {
                let result = Result(idx: Int(coupon.idx),
                                    date: .now,
                                    numbers: try Result.numbersFromString(coupon.numbers!))
                results.append(result)
            }
        } catch {
            print(error)
        }
        savedCoupons.send(results)
    }
}

// MARK: Common operators processing

extension Publisher where Output == Data {
    func processDataStream() -> AnyPublisher<[String], Self.Failure> {
        self.compactMap { data in String(data: data, encoding: .utf8) }
            .map { $0.components(separatedBy: .newlines) }
            .flatMap { $0.publisher }
            .filter { $0.count > 0 }
            .collect()
            .eraseToAnyPublisher()
    }
}
