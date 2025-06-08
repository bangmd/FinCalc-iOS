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
