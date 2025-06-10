//
//  BankAccountsService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation

final class BankAccountsService {
    private var mockAccount = BankAccount(
        id: Int.random(in: 1...100000),
        userID: Int.random(in: 1...100000),
        name: "Основной счет",
        balance: Decimal(string: "102020202") ?? 0,
        currency: "RUB",
        createdAt: DateFormatters.iso8601.date(from: "2024-01-01T12:00:00Z") ?? Date(),
        updatedAt: DateFormatters.iso8601.date(from: "2024-02-01T12:00:00Z") ?? Date()
    )

    func fetchAccount() async throws -> BankAccount {
        return mockAccount
    }

    func updateAccount(id: Int, account: BankAccount) async throws {
        guard mockAccount.id == id else {
            throw NSError(domain: "BankAccountsService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Account not found"])
        }
        mockAccount = account
    }
}
