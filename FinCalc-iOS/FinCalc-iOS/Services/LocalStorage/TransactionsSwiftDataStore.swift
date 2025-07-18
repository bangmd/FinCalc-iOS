//
//  TransactionsSwiftDataStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//
//
//  TransactionsSwiftDataStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//
import Foundation
import SwiftData

final class TransactionsSwiftDataStore: TransactionsPersistenceProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    func fetchAll() async throws -> [TransactionResponse] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<TransactionSDModel>()
        let results = try context.fetch(fetchDescriptor)
        return results.map { $0.toTransactionResponse() }
    }
    
    @MainActor
    func create(_ transaction: TransactionResponse) async throws {
        let context = container.mainContext
        let model = TransactionSDModel(from: transaction)
        context.insert(model)
        try context.save()
    }
    
    @MainActor
    func update(_ transaction: TransactionResponse) async throws {
        let context = container.mainContext
        let id = transaction.id
        let fetchDescriptor = FetchDescriptor<TransactionSDModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let existing = try context.fetch(fetchDescriptor).first {
            existing.amount = transaction.amount
            existing.comment = transaction.comment
            existing.accountId = transaction.account.id
            existing.accountName = transaction.account.name
            existing.accountCurrency = transaction.account.currency
            existing.categoryId = transaction.category.id
            existing.categoryName = transaction.category.name
            existing.categoryEmoji = String(transaction.category.emoji)
            existing.direction = transaction.category.direction.rawValue
            existing.transactionDate = DateFormatters.iso8601.date(from: transaction.transactionDate) ?? Date()
            existing.createdAt = DateFormatters.iso8601.date(from: transaction.createdAt) ?? Date()
            existing.updatedAt = DateFormatters.iso8601.date(from: transaction.updatedAt) ?? Date()
            try context.save()
        }
    }
    
    @MainActor
    func delete(id: Int) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<TransactionSDModel>(predicate: #Predicate { $0.id == id })
        if let toDelete = try context.fetch(fetchDescriptor).first {
            context.delete(toDelete)
            try context.save()
        }
    }
    
    @MainActor
    func fetchById(_ id: Int) async throws -> TransactionResponse? {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<TransactionSDModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(fetchDescriptor).first {
            return model.toTransactionResponse()
        }
        return nil
    }
}
