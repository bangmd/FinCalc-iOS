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
            amount: amount,
            transactionDate: transactionDate,
            comment: comment
        )
    }

    var jsonObject: Any {
        var dict: [String: Any] = [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": amount,
            "transactionDate": transactionDate,
            "createdAt": createdAt,
            "updatedAt": updatedAt
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
            let amount = dict["amount"] as? String,
            let transactionDate = dict["transactionDate"] as? String,
            let createdAt = dict["createdAt"] as? String,
            let updatedAt = dict["updatedAt"] as? String
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
