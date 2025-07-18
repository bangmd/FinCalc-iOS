//
//  CategoriesBackupSwiftDataStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation
import SwiftData

struct CategoryBackup: Sendable, Codable, Identifiable {
    let id: Int
    let action: BackupAction
    let category: Category
}

final class CategoriesBackupSwiftDataStore: CategoriesBackupPersistenceProtocol {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    @MainActor
    func allBackups() async throws -> [CategoryBackup] {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<CategoryBackupSDModel>()
        let results = try context.fetch(fetchDescriptor)
        return results.compactMap { model in
            guard let action = model.action, let cat = model.category else { return nil }
            return CategoryBackup(id: model.id, action: action, category: cat)
        }
    }

    @MainActor
    func addOrUpdateBackup(_ backup: CategoryBackup) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<CategoryBackupSDModel>(
            predicate: #Predicate { $0.id == backup.id }
        )
        if let existing = try context.fetch(fetchDescriptor).first {
            existing.actionRaw = backup.action.rawValue
            existing.categoryData = try JSONEncoder().encode(backup.category)
        } else {
            let model = try CategoryBackupSDModel(
                id: backup.id,
                action: backup.action,
                category: backup.category
            )
            context.insert(model)
        }
        try context.save()
    }

    @MainActor
    func deleteBackup(id: Int) async throws {
        let context = container.mainContext
        let fetchDescriptor = FetchDescriptor<CategoryBackupSDModel>(
            predicate: #Predicate { $0.id == id }
        )
        if let toDelete = try context.fetch(fetchDescriptor).first {
            context.delete(toDelete)
            try context.save()
        }
    }
}
