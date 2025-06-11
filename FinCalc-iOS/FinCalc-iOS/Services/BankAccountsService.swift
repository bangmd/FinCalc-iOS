//
//  BankAccountsService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation

final class BankAccountsService {
    // MARK: - Properties
    private var mockAccounts: [Account] = [
        Account(
            id: 1,
            userId: 123,
            name: "Основной счёт",
            balance: Decimal(string: "1000.00") ?? 0,
            currency: "RUB",
            createdAt: DateFormatters.iso8601.date(from: "2025-06-11T22:05:33.951Z") ?? Date(),
            updatedAt: DateFormatters.iso8601.date(from: "2025-06-11T22:05:33.951Z") ?? Date()
        )
    ]

    // MARK: - Methods
    func fetchAccount() async throws -> Account? {
        return mockAccounts.first
    }

    func updateAccount(id: Int, request: AccountUpdateRequest) async throws -> Account? {
        guard let index = mockAccounts.firstIndex(where: { $0.id == id }) else {
            throw NSError(
                domain: "BankAccountsService",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Account not found"]
            )
        }
        let now = Date()
        let updated = Account(
            id: mockAccounts[index].id,
            userId: mockAccounts[index].userId,
            name: request.name,
            balance: Decimal(string: request.balance) ?? 0,
            currency: request.currency,
            createdAt: mockAccounts[index].createdAt,
            updatedAt: now
        )
        mockAccounts[index] = updated
        return updated
    }
}
