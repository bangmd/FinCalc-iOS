//
//  BankAccountsPersistenceProtocol.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation

protocol BankAccountsPersistenceProtocol: Sendable {
    func fetchAll() async throws -> [Account]
    func create(_ account: Account) async throws
    func update(_ account: Account) async throws
    func delete(id: Int) async throws
    func account(by id: Int) async throws -> Account?
}
