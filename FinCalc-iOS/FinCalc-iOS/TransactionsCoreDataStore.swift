//
//  TransactionsCoreDataStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 19.07.2025.
//
import Foundation
import CoreData

final class TransactionsCoreDataStore: TransactionsPersistenceProtocol {
    private let container: NSPersistentContainer

    init(modelName: String = "FinCalcModel") {
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData failed to load: \(error)")
            }
        }
    }

    private var context: NSManagedObjectContext {
        container.viewContext
    }

    func fetchAll() async throws -> [TransactionResponse] {
        let request: NSFetchRequest<TransactionEntityCD> = TransactionEntityCD.fetchRequest()
        let results = try context.fetch(request)
        return results.compactMap { $0.toTransactionResponse() }
    }

    func fetchById(_ id: Int) async throws -> TransactionResponse? {
        let request: NSFetchRequest<TransactionEntityCD> = TransactionEntityCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        return try context.fetch(request).first?.toTransactionResponse()
    }

    func create(_ transaction: TransactionResponse) async throws {
        let entity = TransactionEntityCD(context: context)
        entity.populate(from: transaction)
        try context.save()
    }

    func update(_ transaction: TransactionResponse) async throws {
        let request: NSFetchRequest<TransactionEntityCD> = TransactionEntityCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", transaction.id)
        if let entity = try context.fetch(request).first {
            entity.populate(from: transaction)
            try context.save()
        }
    }

    func delete(id: Int) async throws {
        let request: NSFetchRequest<TransactionEntityCD> = TransactionEntityCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)
        if let entity = try context.fetch(request).first {
            context.delete(entity)
            try context.save()
        }
    }
}

// MARK: - Mapping Extension
extension TransactionEntityCD {
    func toTransactionResponse() -> TransactionResponse {
        TransactionResponse(
            id: Int(self.id),
            account: AccountBrief(
                id: Int(self.accountId),
                name: self.accountName ?? "",
                balance: self.accountBalance ?? "",
                currency: self.accountCurrency ?? ""
            ),
            category: Category(
                id: Int(self.categoryId),
                name: self.categoryName ?? "",
                emoji: self.categoryEmoji?.first ?? "?",
                direction: Direction(rawValue: self.direction ?? "outcome") ?? .outcome
            ),
            amount: self.amount ?? "0",
            transactionDate: self.transactionDate ?? "",
            comment: self.comment,
            createdAt: self.createdAt ?? "",
            updatedAt: self.updatedAt ?? ""
        )
    }

    func populate(from tx: TransactionResponse) {
        self.id = Int64(tx.id)
        self.accountId = Int64(tx.account.id)
        self.accountName = tx.account.name
        self.accountBalance = tx.account.balance
        self.accountCurrency = tx.account.currency
        self.categoryId = Int64(tx.category.id)
        self.categoryName = tx.category.name
        self.categoryEmoji = String(tx.category.emoji)
        self.direction = tx.category.direction.rawValue
        self.amount = tx.amount
        self.transactionDate = tx.transactionDate
        self.comment = tx.comment
        self.createdAt = tx.createdAt
        self.updatedAt = tx.updatedAt
    }
}
