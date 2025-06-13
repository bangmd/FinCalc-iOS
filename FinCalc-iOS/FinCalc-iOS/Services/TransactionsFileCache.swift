//
//  TransactionsFileCache.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 09.06.2025.
//

import Foundation

final class TransactionsFileCache {
    // MARK: - Public Properties
    private(set) var transactions: [Transaction] = []

    // MARK: - Private Properties
    private let fileURL: URL

    // MARK: - Init
    init(fileURL: URL) {
        self.fileURL = fileURL
    }

    // MARK: - Methods
    func add(_ transaction: Transaction) {
        guard !transactions.contains(where: { $0.id == transaction.id }) else { return }
        transactions.append(transaction)
    }

    func remove(by id: Int) {
        transactions.removeAll(where: {$0.id == id})
    }

    func save() throws {
        let directory = fileURL.deletingLastPathComponent()
        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        let objects = transactions.map { $0.jsonObject }
        let data = try JSONSerialization.data(withJSONObject: objects, options: [.prettyPrinted])
        try data.write(to: fileURL)
    }

    func load() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            transactions = []
            return
        }
        let data = try Data(contentsOf: fileURL)
        let rawArray = try JSONSerialization.jsonObject(with: data)
        guard let array = rawArray as? [Any] else { return }
        var result: [Transaction] = []
        for obj in array {
            if let transaction = Transaction.parse(jsonObject: obj) {
                result.append(transaction)
            }
        }
        self.transactions = result
    }
}
