//
//  Transaction.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import Foundation

struct Transaction: Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: Decimal
    let transactionDate: Date
    let comment: String?
    let createdAt: Date
    let updatedAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }

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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        accountId = try container.decode(Int.self, forKey: .accountId)
        categoryId = try container.decode(Int.self, forKey: .categoryId)

        let amountString = try container.decode(String.self, forKey: .amount)
        guard let amountDecimal = Decimal(string: amountString) else {
            throw DecodingError.dataCorruptedError(forKey: .amount, in: container, debugDescription: "Amount is not a valid decimal string")
        }
        amount = amountDecimal

        comment = try? container.decodeIfPresent(String.self, forKey: .comment)

        let transactionDateString = try container.decode(String.self, forKey: .transactionDate)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)

        guard
            let transactionDateValue = DateFormatters.iso8601.date(from: transactionDateString),
            let createdAtValue = DateFormatters.iso8601.date(from: createdAtString),
            let updatedAtValue = DateFormatters.iso8601.date(from: updatedAtString)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .transactionDate,
                in: container,
                debugDescription: "Date string does not match date format"
            )
        }

        transactionDate = transactionDateValue
        createdAt = createdAtValue
        updatedAt = updatedAtValue
    }
}

extension Transaction {
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
