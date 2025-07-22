//
//  TransactionsService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation

protocol TransactionsServiceProtocol {
    func fetchTransactions(
        accountId: Int,
        startDate: String?,
        endDate: String?
    ) async throws -> [TransactionResponse]
    func updateTransaction(
        id: Int,
        request: TransactionRequest
    ) async throws -> TransactionResponse
    func createTransaction(request: TransactionRequest) async throws -> Transaction
    func deleteTransaction(id: Int) async throws
}

private struct EmptyRequest: Encodable {}
final class TransactionsService: TransactionsServiceProtocol {
    private let client: NetworkClient
    private let persistence: TransactionsPersistenceProtocol
    private let backup: TransactionsBackupPersistenceProtocol
    private let categoriesPersistence: CategoriesPersistenceProtocol
    private let accountsPersistence: BankAccountsPersistenceProtocol
    private let accountsBackup: AccountsBackupPersistenceProtocol
    
    init(
        client: NetworkClient,
        persistence: TransactionsPersistenceProtocol,
        backup: TransactionsBackupPersistenceProtocol,
        categoriesPersistence: CategoriesPersistenceProtocol,
        accountsPersistence: BankAccountsPersistenceProtocol,
        accountsBackup: AccountsBackupPersistenceProtocol
    ) {
        self.client = client
        self.persistence = persistence
        self.backup = backup
        self.categoriesPersistence = categoriesPersistence
        self.accountsPersistence = accountsPersistence
        self.accountsBackup = accountsBackup
    }
    
    // MARK: - Methods
    
    func fetchTransactions(
        accountId: Int,
        startDate: String? = nil,
        endDate: String? = nil
    ) async throws -> [TransactionResponse] {
        try await syncBackupToBackendIfNeeded()
        
        var endpoint = "transactions/account/\(accountId)/period"
        var queryItems: [URLQueryItem] = []
        if let startDate {
            queryItems.append(URLQueryItem(name: "startDate", value: String(startDate.prefix(10))))
        }
        if let endDate {
            queryItems.append(URLQueryItem(name: "endDate", value: String(endDate.prefix(10))))
        }
        if !queryItems.isEmpty {
            var components = URLComponents()
            components.queryItems = queryItems
            if let query = components.percentEncodedQuery {
                endpoint.append("?\(query)")
            }
        }
        
        do {
            let remoteTransactions = try await client.request(
                endpoint: endpoint,
                method: "GET",
                responseType: [TransactionResponse].self
            )
            for transaction in remoteTransactions {
                try await persistence.create(transaction)
            }
            return remoteTransactions
        } catch {
            let allLocal = try await persistence.fetchAll()
            let backupList = try await backup.allBackups().map { $0.transaction }
            let merged = mergeTransactions(primary: allLocal, secondary: backupList)
            let filtered = merged.filter { trx in
                guard trx.account.id == accountId else { return false }
                let trxDate = DateFormatters.iso8601.date(from: trx.transactionDate)
                let start = startDate.flatMap { DateFormatters.iso8601.date(from: $0) }
                let end = endDate.flatMap { DateFormatters.iso8601.date(from: $0) }
                if let trxDate, let start, let end {
                    return (trxDate >= start && trxDate <= end)
                }
                return true
            }
            return filtered
        }
    }
    
    func createTransaction(request: TransactionRequest) async throws -> Transaction {
        do {
            let transaction = try await client.request(
                endpoint: "transactions",
                method: "POST",
                body: request,
                responseType: Transaction.self
            )
            let response = TransactionResponse(
                id: transaction.id,
                account: AccountBrief(
                    id: transaction.accountId, name: "", balance: "", currency: ""),
                category: Category(
                    id: transaction.categoryId, name: "", emoji: "?", direction: .outcome),
                amount: transaction.amount,
                transactionDate: transaction.transactionDate,
                comment: transaction.comment,
                createdAt: transaction.createdAt,
                updatedAt: transaction.updatedAt
            )
            try await persistence.create(response)
            try await backup.deleteBackup(id: transaction.id)
            return transaction
        } catch {
            let category = await categoriesPersistence.category(
                by: request.categoryId
            ) ?? Category(
                id: request.categoryId,
                name: "?",
                emoji: "?",
                direction: .outcome
            )
            let tempId = Int(Date().timeIntervalSince1970)
            let offlineResponse = TransactionResponse(
                id: tempId,
                account: AccountBrief(
                    id: request.accountId, name: "", balance: "", currency: ""),
                category: category,
                amount: request.amount,
                transactionDate: request.transactionDate,
                comment: request.comment,
                createdAt: request.transactionDate,
                updatedAt: request.transactionDate
            )
            try await persistence.create(offlineResponse)
            try await backup.addOrUpdateBackup(TransactionBackup(
                id: tempId, action: .create, transaction: offlineResponse
            ))
            let accountId = request.accountId
            if let account = try? await accountsPersistence.account(by: accountId) {
                let delta = Decimal(string: request.amount) ?? 0
                let newBalance = account.balance + delta
                let updatedAccount = account.withUpdatedBalance(newBalance)
                try? await accountsBackup.addOrUpdateBackup(AccountBackup(
                    id: accountId,
                    action: .update,
                    account: updatedAccount
                ))
            }
            throw error
        }
    }
    
    func updateTransaction(id: Int, request: TransactionRequest) async throws -> TransactionResponse {
        do {
            let updated = try await client.request(
                endpoint: "transactions/\(id)",
                method: "PUT",
                body: request,
                responseType: TransactionResponse.self
            )
            try await persistence.update(updated)
            try await backup.deleteBackup(id: id)
            return updated
        } catch {
            let category = await categoriesPersistence.category(
                by: request.categoryId
            ) ?? Category(
                id: request.categoryId,
                name: "?",
                emoji: "?",
                direction: .outcome
            )
            let offlineUpdate = TransactionResponse(
                id: id,
                account: AccountBrief(
                    id: request.accountId, name: "", balance: "", currency: ""),
                category: category,
                amount: request.amount,
                transactionDate: request.transactionDate,
                comment: request.comment,
                createdAt: request.transactionDate,
                updatedAt: request.transactionDate
            )
            try await persistence.update(offlineUpdate)
            try await backup.addOrUpdateBackup(TransactionBackup(
                id: id, action: .update, transaction: offlineUpdate
            ))
            let accountId = request.accountId
            let oldTx = try? await persistence.fetchById(id)
            let oldAmount = Decimal(string: oldTx?.amount ?? "0") ?? 0
            let newAmount = Decimal(string: request.amount) ?? 0
            let delta = newAmount - oldAmount
            if let account = try? await accountsPersistence.account(by: accountId) {
                let newBalance = account.balance + delta
                let updatedAccount = account.withUpdatedBalance(newBalance)
                try? await accountsBackup.addOrUpdateBackup(AccountBackup(
                    id: accountId,
                    action: .update,
                    account: updatedAccount
                ))
            }
            throw error
        }
    }
    
    func deleteTransaction(id: Int) async throws {
        do {
            let endpoint = "transactions/\(id)"
            _ = try await client.request(
                endpoint: endpoint,
                method: "DELETE",
                responseType: EmptyResponse.self
            )
            try await persistence.delete(id: id)
            try await backup.deleteBackup(id: id)
        } catch {
            let trx = try? await persistence.fetchById(id)
            let delta = -(Decimal(string: trx?.amount ?? "0") ?? 0)
            let accountId = trx?.account.id ?? 0
            try await persistence.delete(id: id)
            let dummy = TransactionResponse(
                id: id,
                account: AccountBrief(id: accountId, name: "", balance: "", currency: ""),
                category: Category(
                    id: trx?.category.id ?? 0,
                    name: trx?.category.name ?? "?",
                    emoji: trx?.category.emoji ?? "?",
                    direction: trx?.category.direction ?? .outcome
                ),
                amount: trx?.amount ?? "0",
                transactionDate: trx?.transactionDate ?? "",
                comment: trx?.comment,
                createdAt: trx?.createdAt ?? "",
                updatedAt: trx?.updatedAt ?? ""
            )
            try await backup.addOrUpdateBackup(TransactionBackup(
                id: id, action: .delete, transaction: dummy
            ))
            if accountId != 0, let account = try? await accountsPersistence.account(by: accountId) {
                let newBalance = account.balance + delta
                let updatedAccount = account.withUpdatedBalance(newBalance)
                try? await accountsBackup.addOrUpdateBackup(AccountBackup(
                    id: accountId,
                    action: .update,
                    account: updatedAccount
                ))
            }
            throw error
        }
    }
    
    // MARK: - Helpers
    private func syncBackupToBackendIfNeeded() async throws {
        let backups = try await backup.allBackups()
        for backupItem in backups {
            switch backupItem.action {
            case .create:
                do {
                    let req = mapToRequest(backupItem.transaction)
                    _ = try await client.request(
                        endpoint: "transactions",
                        method: "POST",
                        body: req,
                        responseType: Transaction.self
                    )
                    try await backup.deleteBackup(id: backupItem.id)
                } catch { continue }
            case .update:
                do {
                    let req = mapToRequest(backupItem.transaction)
                    _ = try await client.request(
                        endpoint: "transactions/\(backupItem.id)",
                        method: "PUT",
                        body: req,
                        responseType: TransactionResponse.self
                    )
                    try await backup.deleteBackup(id: backupItem.id)
                } catch { continue }
            case .delete:
                do {
                    _ = try await client.request(
                        endpoint: "transactions/\(backupItem.id)",
                        method: "DELETE",
                        responseType: EmptyResponse.self
                    )
                    try await backup.deleteBackup(id: backupItem.id)
                } catch { continue }
            }
        }
    }
    
    private func mapToRequest(_ trx: TransactionResponse) -> TransactionRequest {
        TransactionRequest(
            accountId: trx.account.id,
            categoryId: trx.category.id,
            amount: trx.amount,
            transactionDate: trx.transactionDate,
            comment: trx.comment
        )
    }
    
    private func mergeTransactions(
        primary: [TransactionResponse],
        secondary: [TransactionResponse]
    ) -> [TransactionResponse] {
        let secondaryIds = Set(secondary.map { $0.id })
        return secondary + primary.filter { !secondaryIds.contains($0.id) }
    }
}

// MARK: - Helpers for sorting
extension TransactionResponse {
    var date: Date {
        if let date = DateFormatters.iso8601WithFractional.date(from: transactionDate) {
            return date
        }
        if let date = DateFormatters.iso8601WithoutFractional.date(from: transactionDate) {
            return date
        }
        return .distantPast
    }
    var decimalAmount: Decimal {
        Decimal(string: amount) ?? .zero
    }
}
