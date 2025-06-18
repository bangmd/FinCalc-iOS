//
//  Transaction.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import Foundation

// MARK: - API Models
struct TransactionResponse: Identifiable, Decodable {
    let id: Int
    let account: AccountBrief
    let category: Category
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
}

struct TransactionRequest: Encodable {
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
}

// MARK: - Domain Model
struct Transaction: Identifiable, Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date

    init(
        id: Int,
        accountId: Int,
        categoryId: Int,
        amount: Decimal,
        transactionDate: Date,
        comment: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init?(from response: TransactionResponse) {
        guard
            let amount = Decimal(string: response.amount),
            let transactionDate = DateFormatters.iso8601.date(from: response.transactionDate),
            let createdAt = DateFormatters.iso8601.date(from: response.createdAt),
            let updatedAt = DateFormatters.iso8601.date(from: response.updatedAt)
        else { return nil }
        self.id = response.id
        self.accountId = response.account.id
        self.categoryId = response.category.id
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = response.comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
