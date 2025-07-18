//
//  BankAccountsSwiftDataStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation
import SwiftData

final class BankAccountsSwiftDataStore: BankAccountsPersistenceProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    func fetchAll() async throws -> [Account] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<AccountSDModel>()
        let results = try context.fetch(fetchDescriptor)
        return results.map { $0.toAccount() }
    }
    
    @MainActor
    func create(_ account: Account) async throws {
        let context = container.mainContext
        let model = AccountSDModel(from: account)
        context.insert(model)
        try context.save()
    }
    
    @MainActor
    func update(_ account: Account) async throws {
        let context = container.mainContext
        let id = account.id
        let fetchDescriptor = FetchDescriptor<AccountSDModel>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(fetchDescriptor).first {
            existing.name = account.name
            existing.balance = "\(account.balance)"
            existing.currency = account.currency
            existing.userId = account.userId
            existing.createdAt = account.createdAt
            existing.updatedAt = account.updatedAt
            try context.save()
        }
    }
    
    @MainActor
    func delete(id: Int) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<AccountSDModel>(predicate: #Predicate { $0.id == id })
        if let toDelete = try context.fetch(fetchDescriptor).first {
            context.delete(toDelete)
            try context.save()
        }
    }
    
    @MainActor
    func account(by id: Int) async throws -> Account? {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<AccountSDModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let model = try context.fetch(fetchDescriptor).first {
            return model.toAccount()
        }
        return nil
    }
}
