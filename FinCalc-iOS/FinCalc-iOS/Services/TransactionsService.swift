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
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "150100.00", currency: "RUB"),
            category: Category(id: 1, name: "Зарплата", emoji: "💰", direction: .income),
            amount: "500.00",
            transactionDate: "2025-06-22T20:10:25.588Z",
            comment: nil,
            createdAt: "2025-06-10T20:10:25.588Z",
            updatedAt: "2025-06-10T20:10:25.588Z"
        ),
        TransactionResponse(
            id: 2,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "1000.00", currency: "RUB"),
            category: Category(id: 2, name: "Кофе", emoji: "☕️", direction: .outcome),
            amount: "150.00",
            transactionDate: "2025-06-21T10:01:25.000Z",
            comment: "Кофе с утра",
            createdAt: "2025-06-10T20:10:25.588Z",
            updatedAt: "2025-06-10T20:10:25.588Z"
        ),
        TransactionResponse(
            id: 3,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "1000.00", currency: "RUB"),
            category: Category(id: 2, name: "Кофе", emoji: "☕️", direction: .outcome),
            amount: "150.00",
            transactionDate: "2025-06-21T10:01:25.000Z",
            comment: "Кофе с утра",
            createdAt: "2025-06-10T20:10:25.588Z",
            updatedAt: "2025-06-10T20:10:25.588Z"
        ),
        TransactionResponse(
            id: 4,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "1000.00", currency: "RUB"),
            category: Category(id: 4, name: "Техника", emoji: "🚀", direction: .outcome),
            amount: "150000.00",
            transactionDate: "2025-06-21T10:01:25.000Z",
            comment: "Ракета",
            createdAt: "2025-06-10T20:10:25.588Z",
            updatedAt: "2025-06-10T20:10:25.588Z"
        ),
        TransactionResponse(
            id: 5,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "2000.00", currency: "RUB"),
            category: Category(id: 3, name: "Продукты", emoji: "🛒", direction: .outcome),
            amount: "2300.00",
            transactionDate: "2025-06-21T15:30:00.000Z",
            comment: "Гипермаркет",
            createdAt: "2025-06-18T15:31:00.000Z",
            updatedAt: "2025-06-18T15:31:00.000Z"
        ),
        TransactionResponse(
            id: 6,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "50000.00", currency: "RUB"),
            category: Category(id: 1, name: "Зарплата", emoji: "💰", direction: .income),
            amount: "70000.00",
            transactionDate: "2025-06-21T09:00:00.000Z",
            comment: "Зарплата за июнь",
            createdAt: "2025-06-15T09:00:01.000Z",
            updatedAt: "2025-06-15T09:00:01.000Z"
        ),
        TransactionResponse(
            id: 7,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "3000.00", currency: "RUB"),
            category: Category(id: 5, name: "Транспорт", emoji: "🚇", direction: .outcome),
            amount: "58.00",
            transactionDate: "2025-06-20T08:20:00.000Z",
            comment: "Метро",
            createdAt: "2025-06-17T08:20:30.000Z",
            updatedAt: "2025-06-17T08:20:30.000Z"
        ),
        TransactionResponse(
            id: 8,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "150.00", currency: "RUB"),
            category: Category(id: 2, name: "Кофе", emoji: "☕️", direction: .outcome),
            amount: "180.00",
            transactionDate: "2025-06-20T10:05:00.000Z",
            comment: "Латте",
            createdAt: "2025-06-16T10:05:10.000Z",
            updatedAt: "2025-06-16T10:05:10.000Z"
        ),
        TransactionResponse(
            id: 9,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "500.00", currency: "RUB"),
            category: Category(id: 6, name: "Инвестиции", emoji: "📈", direction: .outcome),
            amount: "10000.00",
            transactionDate: "2025-06-20T12:00:00.000Z",
            comment: nil,
            createdAt: "2025-06-14T12:00:10.000Z",
            updatedAt: "2025-06-14T12:00:10.000Z"
        ),
        TransactionResponse(
            id: 10,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "100.00", currency: "RUB"),
            category: Category(id: 7, name: "Кэшбэк", emoji: "🎁", direction: .income),
            amount: "350.00",
            transactionDate: "2025-06-22T18:45:00.000Z",
            comment: "Кэшбэк Тинькофф",
            createdAt: "2025-06-13T18:45:10.000Z",
            updatedAt: "2025-06-13T18:45:10.000Z"
        ),
        TransactionResponse(
            id: 11,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "180.00", currency: "RUB"),
            category: Category(id: 3, name: "Продукты", emoji: "🛒", direction: .outcome),
            amount: "1240.00",
            transactionDate: "2025-06-12T17:20:00.000Z",
            comment: "Ужин",
            createdAt: "2025-06-12T17:20:05.000Z",
            updatedAt: "2025-06-12T17:20:05.000Z"
        ),
        TransactionResponse(
            id: 12,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "400.00", currency: "RUB"),
            category: Category(id: 8, name: "Интернет", emoji: "🌐", direction: .outcome),
            amount: "800.00",
            transactionDate: "2025-06-11T11:00:00.000Z",
            comment: "Оплата интернета",
            createdAt: "2025-06-11T11:00:10.000Z",
            updatedAt: "2025-06-11T11:00:10.000Z"
        ),
        TransactionResponse(
            id: 13,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "520.00", currency: "RUB"),
            category: Category(id: 9, name: "Хобби", emoji: "🎸", direction: .outcome),
            amount: "2500.00",
            transactionDate: "2025-06-10T19:30:00.000Z",
            comment: "Струны",
            createdAt: "2025-06-10T19:30:05.000Z",
            updatedAt: "2025-06-10T19:30:05.000Z"
        ),
        TransactionResponse(
            id: 14,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "160.00", currency: "RUB"),
            category: Category(id: 10, name: "Подарки", emoji: "🎂", direction: .outcome),
            amount: "3200.00",
            transactionDate: "2025-06-09T14:10:00.000Z",
            comment: "День рождения",
            createdAt: "2025-06-09T14:10:05.000Z",
            updatedAt: "2025-06-09T14:10:05.000Z"
        ),
        TransactionResponse(
            id: 15,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "500.00", currency: "RUB"),
            category: Category(id: 1, name: "Зарплата", emoji: "💰", direction: .income),
            amount: "65000.00",
            transactionDate: "2025-06-21T09:00:00.000Z",
            comment: "Зарплата за май",
            createdAt: "2025-05-31T09:00:10.000Z",
            updatedAt: "2025-05-31T09:00:10.000Z"
        ),
        TransactionResponse(
            id: 16,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "280.00", currency: "RUB"),
            category: Category(id: 2, name: "Кофе", emoji: "☕️", direction: .outcome),
            amount: "190.00",
            transactionDate: "2025-06-02T09:30:00.000Z",
            comment: "Флэт у офиса",
            createdAt: "2025-06-02T09:30:05.000Z",
            updatedAt: "2025-06-02T09:30:05.000Z"
        ),
        TransactionResponse(
            id: 17,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "123.00", currency: "RUB"),
            category: Category(id: 11, name: "Обучение", emoji: "📚", direction: .outcome),
            amount: "5000.00",
            transactionDate: "2025-06-05T13:00:00.000Z",
            comment: "Swift курс",
            createdAt: "2025-06-05T13:00:10.000Z",
            updatedAt: "2025-06-05T13:00:10.000Z"
        ),
        TransactionResponse(
            id: 18,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "80.00", currency: "RUB"),
            category: Category(id: 7, name: "Кэшбэк", emoji: "🎁", direction: .income),
            amount: "120.00",
            transactionDate: "2025-06-03T12:00:00.000Z",
            comment: "Кэшбэк Ozon",
            createdAt: "2025-06-03T12:00:05.000Z",
            updatedAt: "2025-06-03T12:00:05.000Z"
        ),
        TransactionResponse(
            id: 19,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "300.00", currency: "RUB"),
            category: Category(id: 3, name: "Продукты", emoji: "🛒", direction: .outcome),
            amount: "2150.00",
            transactionDate: "2025-06-01T18:20:00.000Z",
            comment: "Ашан",
            createdAt: "2025-06-01T18:20:05.000Z",
            updatedAt: "2025-06-01T18:20:05.000Z"
        ),
        TransactionResponse(
            id: 20,
            account: AccountBrief(id: 1, name: "Основной счёт", balance: "999.00", currency: "RUB"),
            category: Category(id: 12, name: "Ресторан", emoji: "🍣", direction: .outcome),
            amount: "4800.00",
            transactionDate: "2025-06-06T21:15:00.000Z",
            comment: "Ужин в суши-баре",
            createdAt: "2025-06-06T21:15:05.000Z",
            updatedAt: "2025-06-06T21:15:05.000Z"
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

// MARK: - Helpers for sorting
extension TransactionResponse {
    var date: Date {
        DateFormatters.iso8601.date(from: transactionDate) ?? .distantPast
    }

    var decimalAmount: Decimal {
        Decimal(string: amount) ?? .zero
    }
}
