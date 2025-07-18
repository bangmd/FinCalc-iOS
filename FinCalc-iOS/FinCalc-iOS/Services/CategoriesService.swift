//
//  CategoriesService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation
protocol CategoriesServiceProtocol {
    func getAllCategories() async throws -> [Category]
    func getCategoriesByType(direction: Direction) async throws -> [Category]
}

final class CategoriesService: CategoriesServiceProtocol {
    // MARK: - Properties
    private let client: NetworkClient
    
    init(client: NetworkClient) {
        self.client = client
    }
    
    // MARK: - Methods
    func getAllCategories() async throws -> [Category] {
        return try await client.request(
            endpoint: "categories",
            method: "GET",
            responseType: [Category].self
        )
    }
    
    func getCategoriesByType(direction: Direction) async throws -> [Category] {
        let isIncome = (direction == .income)
        let endpoint = "categories/type/\(isIncome)"
        return try await client.request(
            endpoint: endpoint,
            method: "GET",
            responseType: [Category].self
        )
    }
}
