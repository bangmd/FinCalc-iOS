//
//  BankAccount.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import Foundation

struct BankAccount: Decodable {
    let id: Int
    let userId: Int
    let name: String
    let balance: Decimal
    let currency: String
    let createdAt: Date
    let updatedAt: Date
    
    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case name
        case balance
        case currency
        case createdAt
        case updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let balanceDecimal = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(forKey: .balance, in: container, debugDescription: "Balance is not a valid decimal string")
        }
        balance = balanceDecimal
        currency = try container.decode(String.self, forKey: .currency)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        let formatter = ISO8601DateFormatter()
        guard
            let created = formatter.date(from: createdAtString),
            let updated = formatter.date(from: updatedAtString)
        else {
            throw DecodingError.dataCorruptedError(forKey: .createdAt, in: container, debugDescription: "Date string does not match date format")
        }
        createdAt = created
        updatedAt = updated
    }
}
