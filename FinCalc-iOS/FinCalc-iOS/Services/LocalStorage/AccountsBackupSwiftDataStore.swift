//
//  AccountsBackupSwiftDataStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation
import SwiftData

final class AccountsBackupSwiftDataStore: AccountsBackupPersistenceProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    func allBackups() async throws -> [AccountBackup] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<AccountBackupSDModel>()
        let results = try context.fetch(fetchDescriptor)
        return results.compactMap { model in
            guard let action = model.action, let account = model.account else { return nil }
            return AccountBackup(id: model.id, action: action, account: account)
        }
    }
    
    @MainActor
    func addOrUpdateBackup(_ backup: AccountBackup) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<AccountBackupSDModel>(
            predicate: #Predicate { $0.id == backup.id }
        )
        if let existing = try context.fetch(fetchDescriptor).first {
            existing.actionRaw = backup.action.rawValue
            existing.accountData = try JSONEncoder().encode(backup.account)
        } else {
            let model = try AccountBackupSDModel(
                id: backup.id,
                action: backup.action,
                account: backup.account
            )
            context.insert(model)
        }
        try context.save()
    }
    
    @MainActor
    func deleteBackup(id: Int) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<AccountBackupSDModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let toDelete = try context.fetch(fetchDescriptor).first {
            context.delete(toDelete)
            try context.save()
        }
    }
}
