//
//  BankAccountsService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation

protocol BankAccountsServiceProtocol {
    func fetchAccount() async throws -> Account?
    func fetchAllAccounts() async throws -> [Account]
    func updateAccount(id: Int, request: AccountUpdateRequest) async throws -> Account?
}

final class BankAccountsService: BankAccountsServiceProtocol {
    // MARK: - Properties
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    // MARK: - Methods
    func fetchAllAccounts() async throws -> [Account] {
        return try await client.request(
            endpoint: "accounts",
            method: "GET",
            responseType: [Account].self
        )
    }
    
    func fetchAccount() async throws -> Account? {
        let accounts = try await fetchAllAccounts()
        return accounts.first
    }
    
    func updateAccount(id: Int, request: AccountUpdateRequest) async throws -> Account? {
        return try await client.request(
            endpoint: "accounts/\(id)",
            method: "PUT",
            body: request,
            responseType: Account.self
        )
    }
}
