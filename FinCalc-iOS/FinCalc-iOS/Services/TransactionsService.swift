//
//  TransactionsService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation

final class TransactionsService {
    // MARK: - Properties
    private let cache = TransactionsFileCache()

    // MARK: - Methods
    func transaction(id: Int) async throws -> Transaction? {
        cache.transactions.first { $0.id == id }
    }

    func transactions(accountId: Int, from startDate: Date, to endDate: Date) async throws -> [Transaction] {
        cache.transactions.filter {
            $0.accountId == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
    }

    func create(transaction: Transaction) async throws {
        cache.add(transaction)
    }

    func update(id: Int, newTransaction: Transaction) async throws {
        cache.remove(by: id)
        cache.add(newTransaction)
    }

    func delete(id: Int) async throws {
        cache.remove(by: id)
    }
}
