//
//  TransactionSDModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation
import SwiftData

@Model
final class TransactionSDModel {
    @Attribute(.unique) var id: Int
    var accountId: Int
    var accountName: String
    var accountCurrency: String
    var categoryId: Int
    var categoryName: String
    var categoryEmoji: String
    var direction: String
    var amount: String
    var transactionDate: Date
    var comment: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: Int,
        accountId: Int,
        accountName: String,
        accountCurrency: String,
        categoryId: Int,
        categoryName: String,
        categoryEmoji: String,
        direction: String,
        amount: String,
        transactionDate: Date,
        comment: String?,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.accountId = accountId
        self.accountName = accountName
        self.accountCurrency = accountCurrency
        self.categoryId = categoryId
        self.categoryName = categoryName
        self.categoryEmoji = categoryEmoji
        self.direction = direction
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension TransactionSDModel {
    convenience init(from response: TransactionResponse) {
        self.init(
            id: response.id,
            accountId: response.account.id,
            accountName: response.account.name,
            accountCurrency: response.account.currency,
            categoryId: response.category.id,
            categoryName: response.category.name,
            categoryEmoji: String(response.category.emoji),
            direction: response.category.direction.rawValue,
            amount: response.amount,
            transactionDate: DateFormatters.iso8601.date(from: response.transactionDate) ?? Date(),
            comment: response.comment,
            createdAt: DateFormatters.iso8601.date(from: response.createdAt) ?? Date(),
            updatedAt: DateFormatters.iso8601.date(from: response.updatedAt) ?? Date()
        )
    }
    
    func toTransactionResponse() -> TransactionResponse {
        TransactionResponse(
            id: id,
            account: AccountBrief(id: accountId, name: accountName, balance: "", currency: accountCurrency),
            category: Category(
                id: categoryId,
                name: categoryName,
                emoji: categoryEmoji.first ?? " ",
                direction: Direction(rawValue: direction) ?? .outcome
            ),
            amount: amount,
            transactionDate: DateFormatters.iso8601.string(from: transactionDate),
            comment: comment,
            createdAt: DateFormatters.iso8601.string(from: createdAt),
            updatedAt: DateFormatters.iso8601.string(from: updatedAt)
        )
    }
}
