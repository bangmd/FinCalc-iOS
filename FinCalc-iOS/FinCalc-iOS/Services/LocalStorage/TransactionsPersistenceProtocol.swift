//
//  TransactionsLocalStorageProtocol.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation

protocol TransactionsPersistenceProtocol {
    func fetchAll() async throws -> [TransactionResponse]
    func create(_ transaction: TransactionResponse) async throws
    func update(_ transaction: TransactionResponse) async throws
    func delete(id: Int) async throws
    func fetchById(_ id: Int) async throws -> TransactionResponse?
}
