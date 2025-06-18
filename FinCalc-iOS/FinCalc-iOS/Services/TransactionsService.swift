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
}

final class TransactionsService: TransactionsServiceProtocol {
    // MARK: - Properties
    private var nextId: Int {
        (mockTransactionResponses.map { $0.id }.max() ?? 0) + 1
    }
    private var mockTransactionResponses: [TransactionResponse] = [
        TransactionResponse(
            id: 1,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "1000.00", currency: "RUB"),
            category: Category(id: 1, name: "Зарплата", emoji: "💰", direction: .income),
            amount: "500.00",
            transactionDate: "2025-06-18T20:10:25.588Z",
            comment: nil,
            createdAt: "2025-06-10T20:10:25.588Z",
            updatedAt: "2025-06-10T20:10:25.588Z"
        ),
        TransactionResponse(
            id: 2,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "1000.00", currency: "RUB"),
            category: Category(id: 2, name: "Кофе", emoji: "☕️", direction: .income),
            amount: "150.00",
            transactionDate: "2025-06-18T10:01:25.000Z",
            comment: "Кофе с утра",
            createdAt: "2025-06-10T20:10:25.588Z",
            updatedAt: "2025-06-10T20:10:25.588Z"
        ),
        TransactionResponse(
            id: 3,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "1000.00", currency: "RUB"),
            category: Category(id: 2, name: "Кофе", emoji: "☕️", direction: .outcome),
            amount: "150.00",
            transactionDate: "2025-06-18T10:01:25.000Z",
            comment: "Кофе с утра",
            createdAt: "2025-06-10T20:10:25.588Z",
            updatedAt: "2025-06-10T20:10:25.588Z"
        ),
        TransactionResponse(
            id: 4,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "1000.00", currency: "RUB"),
            category: Category(id: 4, name: "Техника", emoji: "🚀", direction: .outcome),
            amount: "15000.00",
            transactionDate: "2025-06-18T10:01:25.000Z",
            comment: "Ракета",
            createdAt: "2025-06-10T20:10:25.588Z",
            updatedAt: "2025-06-10T20:10:25.588Z"
        )
    ]

    // MARK: - Methods
    func fetchTransactions(
        accountId: Int,
        startDate: String? = nil,
        endDate: String? = nil
    ) async throws -> [TransactionResponse] {
        return mockTransactionResponses.filter { transactionResponse in
            guard transactionResponse.account.id == accountId else {
                return false
            }
            guard let transactionDate = DateFormatters.iso8601.date(from: transactionResponse.transactionDate) else {
                return false
            }
            if let startDateString = startDate,
               let startDateValue = DateFormatters.iso8601.date(from: startDateString),
               transactionDate < startDateValue {
                return false
            }
            if let endDateString = endDate,
               let endDateValue = DateFormatters.iso8601.date(from: endDateString),
               transactionDate > endDateValue {
                return false
            }
            return true
        }
    }

    func createTransaction(request: TransactionRequest) async throws -> Transaction {
        let now = Date()
        let id = nextId
        return Transaction(
            id: id,
            accountId: request.accountId,
            categoryId: request.categoryId,
            amount: Decimal(string: request.amount) ?? 0,
            transactionDate: DateFormatters.iso8601.date(from: request.transactionDate) ?? now,
            comment: request.comment,
            createdAt: now,
            updatedAt: now
        )
    }

    func updateTransaction(id: Int, request: TransactionRequest) async throws -> TransactionResponse {
        guard let index = mockTransactionResponses.firstIndex(where: { $0.id == id }) else {
            throw NSError(
                domain: "TransactionsService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Transaction not found"]
            )
        }

        let now = DateFormatters.iso8601.string(from: Date())
        let old = mockTransactionResponses[index]
        let updated = TransactionResponse(
            id: id,
            account: old.account,
            category: old.category,
            amount: request.amount,
            transactionDate: request.transactionDate,
            comment: request.comment,
            createdAt: old.createdAt,
            updatedAt: now
        )

        mockTransactionResponses[index] = updated
        return updated
    }

    func deleteTransaction(id: Int) async throws {
        guard let index = mockTransactionResponses.firstIndex(where: { $0.id == id }) else {
            throw NSError(
                domain: "TransactionsService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Transaction not found"]
            )
        }

        mockTransactionResponses.remove(at: index)
    }
}
