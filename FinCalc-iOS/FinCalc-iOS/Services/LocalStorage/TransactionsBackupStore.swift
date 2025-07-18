//
//  TransactionsBackupStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
import Foundation
import SwiftData

final class TransactionsBackupSwiftDataStore: TransactionsBackupPersistenceProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    func allBackups() async throws -> [TransactionBackup] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<TransactionBackupSDModel>()
        let results = try context.fetch(fetchDescriptor)
        return results.compactMap { model in
            guard let action = model.action, let trx = model.transactionResponse else { return nil }
            return TransactionBackup(id: model.id, action: action, transaction: trx)
        }
    }
    
    @MainActor
    func addOrUpdateBackup(_ backup: TransactionBackup) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<TransactionBackupSDModel>(
            predicate: #Predicate { $0.id == backup.id }
        )
        if let existing = try context.fetch(fetchDescriptor).first {
            existing.actionRaw = backup.action.rawValue
            existing.transactionData = try JSONEncoder().encode(backup.transaction)
        } else {
            let model = try TransactionBackupSDModel(
                id: backup.id,
                action: backup.action,
                transaction: backup.transaction
            )
            context.insert(model)
        }
        try context.save()
    }
    
    @MainActor
    func deleteBackup(id: Int) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<TransactionBackupSDModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let toDelete = try context.fetch(fetchDescriptor).first {
            context.delete(toDelete)
            try context.save()
        }
    }
}
