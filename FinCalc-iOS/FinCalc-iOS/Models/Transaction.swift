//
//  Transaction.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import Foundation

struct TransactionResponse: Decodable {
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

struct Transaction: Decodable {
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

extension Transaction {
    var request: TransactionRequest {
        TransactionRequest(
            accountId: accountId,
            categoryId: categoryId,
            amount: "\(amount)",
            transactionDate: DateFormatters.iso8601.string(from: transactionDate),
            comment: comment
        )
    }

    var jsonObject: Any {
        var dict: [String: Any] = [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": "\(amount)",
            "transactionDate": DateFormatters.iso8601.string(from: transactionDate),
            "createdAt": DateFormatters.iso8601.string(from: createdAt),
            "updatedAt": DateFormatters.iso8601.string(from: updatedAt)
        ]
        if let comment = comment {
            dict["comment"] = comment
        }
        return dict
    }

    static func parse(jsonObject: Any) -> Transaction? {
        guard let dict = jsonObject as? [String: Any] else { return nil }
        guard
            let id = dict["id"] as? Int,
            let accountId = dict["accountId"] as? Int,
            let categoryId = dict["categoryId"] as? Int,
            let amountString = dict["amount"] as? String,
            let amount = Decimal(string: amountString),
            let transactionDateString = dict["transactionDate"] as? String,
            let transactionDate = DateFormatters.iso8601.date(from: transactionDateString),
            let createdAtString = dict["createdAt"] as? String,
            let createdAt = DateFormatters.iso8601.date(from: createdAtString),
            let updatedAtString = dict["updatedAt"] as? String,
            let updatedAt = DateFormatters.iso8601.date(from: updatedAtString)
        else {
            return nil
        }
        let comment = dict["comment"] as? String

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
