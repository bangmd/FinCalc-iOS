//
//  AccountSDModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//
import Foundation
import SwiftData

@Model
final class AccountSDModel {
    @Attribute(.unique) var id: Int
    var userId: Int
    var name: String
    var balance: String
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, userId: Int, name: String, balance: String, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init(from account: Account) {
        self.init(
            id: account.id,
            userId: account.userId,
            name: account.name,
            balance: "\(account.balance)",
            currency: account.currency,
            createdAt: account.createdAt,
            updatedAt: account.updatedAt
        )
    }
    
    func toAccount() -> Account {
        Account(
            id: id,
            userId: userId,
            name: name,
            balance: Decimal(string: balance) ?? .zero,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
