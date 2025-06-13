//
//  Transaction+parseJSON.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 13.06.2025.
//

import Foundation

// MARK: - JSON Conversion
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
