//
//  Transaction.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import Foundation

// MARK: - API Models
struct TransactionResponse: Identifiable, Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountId, forKey: .accountId)
        try container.encode(categoryId, forKey: .categoryId)
        if let amountDecimal = Decimal(string: amount) {
            try container.encode(amountDecimal, forKey: .amount)
        } else {
            throw EncodingError.invalidValue(amount, EncodingError.Context(
                codingPath: [CodingKeys.amount],
                debugDescription: "Invalid decimal string"
            ))
        }
        try container.encode(transactionDate, forKey: .transactionDate)
        if let comment = comment, !comment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try container.encode(comment, forKey: .comment)
        } else {
            try container.encodeNil(forKey: .comment)
        }
    }
}

// MARK: - Domain Model
struct Transaction: Identifiable, Decodable {
    let id: Int
    let accountId: Int
    let categoryId: Int
    let amount: String
    let transactionDate: String
    let comment: String?
    let createdAt: String
    let updatedAt: String
}
