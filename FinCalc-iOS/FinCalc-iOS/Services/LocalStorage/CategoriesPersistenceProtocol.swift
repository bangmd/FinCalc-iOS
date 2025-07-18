//
//  CategoriesPersistenceProtocol.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation

protocol CategoriesPersistenceProtocol: Sendable {
    func fetchAll() async throws -> [Category]
    func update(_ category: Category) async throws
    func create(_ category: Category) async throws
    func delete(id: Int) async throws
    func category(by id: Int) async -> Category?
}
