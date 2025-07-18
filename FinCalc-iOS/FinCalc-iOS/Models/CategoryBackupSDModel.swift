//
//  CategoryBackupSDModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation
import SwiftData

@Model
final class CategoryBackupSDModel {
    @Attribute(.unique) var id: Int
    var actionRaw: String
    var categoryData: Data
    
    init(id: Int, action: BackupAction, category: Category) throws {
        self.id = id
        self.actionRaw = action.rawValue
        self.categoryData = try JSONEncoder().encode(category)
    }
    
    var action: BackupAction? {
        BackupAction(rawValue: actionRaw)
    }
    
    var category: Category? {
        try? JSONDecoder().decode(Category.self, from: categoryData)
    }
}
