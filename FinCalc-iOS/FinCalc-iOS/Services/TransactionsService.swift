//
//  TransactionsService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation

protocol TransactionsServiceProtocol {
    func fetchTransactions(
        accountId: Int,
        startDate: String?,
        endDate: String?
    ) async throws -> [TransactionResponse]
    func updateTransaction(
        id: Int,
        request: TransactionRequest
    ) async throws -> TransactionResponse
    func createTransaction(request: TransactionRequest) async throws -> Transaction
    func deleteTransaction(id: Int) async throws
}

private struct EmptyRequest: Encodable {}

final class TransactionsService: TransactionsServiceProtocol {
    // MARK: - Properties
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    // MARK: - Methods
    func fetchTransactions(
        accountId: Int,
        startDate: String? = nil,
        endDate: String? = nil
    ) async throws -> [TransactionResponse] {
        var endpoint = "transactions/account/\(accountId)/period"
        
        var queryItems: [URLQueryItem] = []
        if let startDate {
            queryItems.append(URLQueryItem(name: "startDate", value: String(startDate.prefix(10)))) // YYYY-MM-DD
        }
        if let endDate {
            queryItems.append(URLQueryItem(name: "endDate", value: String(endDate.prefix(10))))
        }
        
        if !queryItems.isEmpty {
            var components = URLComponents()
            components.queryItems = queryItems
            if let query = components.percentEncodedQuery {
                endpoint.append("?\(query)")
            }
        }
        
        return try await client.request(
            endpoint: endpoint,
            method: "GET",
            responseType: [TransactionResponse].self
        )
    }
    
    func createTransaction(request: TransactionRequest) async throws -> Transaction {
        return try await client.request(
            endpoint: "transactions",
            method: "POST",
            body: request,
            responseType: Transaction.self)
    }
    
    func updateTransaction(id: Int, request: TransactionRequest) async throws -> TransactionResponse {
        let endpoint = "transactions/\(id)"
        return try await client.request(
            endpoint: endpoint,
            method: "PUT",
            body: request,
            responseType: TransactionResponse.self)
    }
    
    func deleteTransaction(id: Int) async throws {
        let endpoint = "transactions/\(id)"
        _ = try await client.request(
            endpoint: endpoint,
            method: "DELETE",
            responseType: EmptyResponse.self
        )
    }
}

// MARK: - Helpers for sorting
extension TransactionResponse {
    var date: Date {
        DateFormatters.iso8601.date(from: transactionDate) ?? .distantPast
    }
    
    var decimalAmount: Decimal {
        Decimal(string: amount) ?? .zero
    }
}
