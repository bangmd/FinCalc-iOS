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
    func updateCategory(_ category: Category) async throws
    func createCategory(_ category: Category) async throws
    func deleteCategory(id: Int) async throws
}

final class CategoriesService: CategoriesServiceProtocol {
    private let client: NetworkClient
    private let persistence: CategoriesPersistenceProtocol
    private let backup: CategoriesBackupPersistenceProtocol
    
    init(
        client: NetworkClient,
        persistence: CategoriesPersistenceProtocol,
        backup: CategoriesBackupPersistenceProtocol
    ) {
        self.client = client
        self.persistence = persistence
        self.backup = backup
    }
    
    // MARK: - Получение категорий
    func getAllCategories() async throws -> [Category] {
        do {
            let categories = try await client.request(
                endpoint: "categories",
                method: "GET",
                responseType: [Category].self
            )
            for cat in categories {
                try await persistence.create(cat)
            }
            return categories
        } catch {
            return try await persistence.fetchAll()
        }
    }
    
    func getCategoriesByType(direction: Direction) async throws -> [Category] {
        let all = try await getAllCategories()
        return all.filter { $0.direction == direction }
    }
    
    // MARK: - CRUD
    func createCategory(_ category: Category) async throws {
        let backup = CategoryBackup(id: category.id, action: .create, category: category)
        try await self.backup.addOrUpdateBackup(backup)
        
        try await persistence.create(category)
        
        _ = try? await client.request(
            endpoint: "categories",
            method: "POST",
            body: category,
            responseType: Category.self
        )
    }
    
    func updateCategory(_ category: Category) async throws {
        let backup = CategoryBackup(id: category.id, action: .update, category: category)
        try await self.backup.addOrUpdateBackup(backup)
        
        try await persistence.update(category)
        
        _ = try? await client.request(
            endpoint: "categories/\(category.id)",
            method: "PUT",
            body: category,
            responseType: Category.self
        )
    }
    
    func deleteCategory(id: Int) async throws {
        let backup = CategoryBackup(
            id: id,
            action: .delete,
            category: Category(
                id: id,
                name: "",
                emoji: "❓",
                direction: .outcome
            )
        )
        try await self.backup.addOrUpdateBackup(backup)
        
        try await persistence.delete(id: id)
        
        _ = try? await client.request(
            endpoint: "categories/\(id)",
            method: "DELETE",
            responseType: EmptyResponse.self
        )
    }
}
