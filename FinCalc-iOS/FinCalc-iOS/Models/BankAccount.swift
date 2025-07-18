//
//  BankAccount.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import Foundation

struct AccountBrief: Codable {
    let id: Int
    let name: String
    let balance: String
    let currency: String
}

struct AccountUpdateRequest: Codable {
    let name: String
    let balance: String
    let currency: String
}

struct Account: Codable {
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
    
    init(
        id: Int,
        userId: Int,
        name: String,
        balance: Decimal,
        currency: String,
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        
        let balanceString = try container.decode(String.self, forKey: .balance)
        guard let balanceDecimal = Decimal(string: balanceString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .balance,
                in: container,
                debugDescription: "Balance is not a valid decimal string"
            )
        }
        balance = balanceDecimal
        
        currency = try container.decode(String.self, forKey: .currency)
        
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        guard
            let created = DateFormatters.iso8601.date(from: createdAtString),
            let updated = DateFormatters.iso8601.date(from: updatedAtString)
        else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Date string does not match date format"
            )
        }
        createdAt = created
        updatedAt = updated
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode("\(balance)", forKey: .balance) 
        try container.encode(currency, forKey: .currency)
        try container.encode(DateFormatters.iso8601.string(from: createdAt), forKey: .createdAt)
        try container.encode(DateFormatters.iso8601.string(from: updatedAt), forKey: .updatedAt)
    }
}

extension Account {
    func withUpdatedBalance(_ newBalance: Decimal) -> Account {
        Account(
            id: id,
            userId: userId,
            name: name,
            balance: newBalance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
