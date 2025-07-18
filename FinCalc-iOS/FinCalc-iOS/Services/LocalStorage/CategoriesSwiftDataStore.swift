//
//  CategoriesSwiftDataStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//
import Foundation
import SwiftData

final class CategoriesSwiftDataStore: CategoriesPersistenceProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    @MainActor
    func fetchAll() async throws -> [Category] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<CategorySDModel>()
        let results = try context.fetch(fetchDescriptor)
        return results.map { $0.toCategory() }
    }
    
    @MainActor
    func create(_ category: Category) async throws {
        let context = container.mainContext
        let model = CategorySDModel(from: category)
        context.insert(model)
        try context.save()
    }
    
    @MainActor
    func update(_ category: Category) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<CategorySDModel>(
            predicate: #Predicate { $0.id == category.id }
        )
        if let existing = try context.fetch(fetchDescriptor).first {
            existing.name = category.name
            existing.emoji = String(category.emoji)
            existing.isIncome = category.direction == .income
            try context.save()
        }
    }
    
    @MainActor
    func delete(id: Int) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<CategorySDModel>(predicate: #Predicate { $0.id == id })
        if let toDelete = try context.fetch(fetchDescriptor).first {
            context.delete(toDelete)
            try context.save()
        }
    }
    
    @MainActor
    func category(by id: Int) async -> Category? {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<CategorySDModel>(predicate: #Predicate { $0.id == id })
        if let found = try? context.fetch(fetchDescriptor).first {
            return found.toCategory()
        }
        return nil
    }
}
