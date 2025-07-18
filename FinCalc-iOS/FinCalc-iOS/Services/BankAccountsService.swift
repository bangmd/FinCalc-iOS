//
//  BankAccountsService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.

import Foundation

protocol BankAccountsServiceProtocol {
    func fetchAccount() async throws -> Account?
    func fetchAllAccounts() async throws -> [Account]
    func updateAccount(id: Int, request: AccountUpdateRequest) async throws -> Account?
}

final class BankAccountsService: BankAccountsServiceProtocol {
    // MARK: - Properties
    private let client: NetworkClient
    private let persistence: BankAccountsPersistenceProtocol
    private let backup: AccountsBackupPersistenceProtocol
    
    init(
        client: NetworkClient,
        persistence: BankAccountsPersistenceProtocol,
        backup: AccountsBackupPersistenceProtocol
    ) {
        self.client = client
        self.persistence = persistence
        self.backup = backup
    }
    
    // MARK: - Methods
    
    func fetchAllAccounts() async throws -> [Account] {
        try await syncBackupToBackendIfNeeded()
        do {
            let accounts = try await client.request(
                endpoint: "accounts",
                method: "GET",
                responseType: [Account].self
            )
            for acc in accounts {
                try await persistence.create(acc)
            }
            return accounts
        } catch {
            let allLocal = try await persistence.fetchAll()
            let backupList = try await backup.allBackups().map { $0.account }
            return mergeAccounts(primary: allLocal, secondary: backupList)
        }
    }
    
    func fetchAccount() async throws -> Account? {
        let accounts = try await fetchAllAccounts()
        return accounts.first
    }
    
    func updateAccount(id: Int, request: AccountUpdateRequest) async throws -> Account? {
        do {
            let account = try await client.request(
                endpoint: "accounts/\(id)",
                method: "PUT",
                body: request,
                responseType: Account.self
            )
            try await persistence.update(account)
            try await backup.deleteBackup(id: id)
            return account
        } catch {
            let offlineUpdate = Account(
                id: id,
                userId: 0,
                name: request.name,
                balance: Decimal(string: request.balance) ?? 0,
                currency: request.currency,
                createdAt: Date(),
                updatedAt: Date()
            )
            try await backup.addOrUpdateBackup(AccountBackup(id: id, action: .update, account: offlineUpdate))
            throw error
        }
    }
    
    // MARK: - Helpers
    private func syncBackupToBackendIfNeeded() async throws {
        let backups = try await backup.allBackups()
        for backupItem in backups {
            switch backupItem.action {
            case .update:
                do {
                    let req = AccountUpdateRequest(
                        name: backupItem.account.name,
                        balance: "\(backupItem.account.balance)",
                        currency: backupItem.account.currency
                    )
                    _ = try await client.request(
                        endpoint: "accounts/\(backupItem.id)",
                        method: "PUT",
                        body: req,
                        responseType: Account.self
                    )
                    try await backup.deleteBackup(id: backupItem.id)
                } catch { continue }
            case .create:
                continue
            case .delete:
                continue
            }
        }
    }
    
    private func mergeAccounts(primary: [Account], secondary: [Account]) -> [Account] {
        let secondaryIds = Set(secondary.map { $0.id })
        return secondary + primary.filter { !secondaryIds.contains($0.id) }
    }
}
