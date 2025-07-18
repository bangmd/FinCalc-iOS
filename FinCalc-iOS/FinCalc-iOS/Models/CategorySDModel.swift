//
//  CategorySDModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//
import Foundation
import SwiftData

@Model
final class CategorySDModel {
    @Attribute(.unique) var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool
    
    init(id: Int, name: String, emoji: String, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }
    
    convenience init(from category: Category) {
        self.init(
            id: category.id,
            name: category.name,
            emoji: String(category.emoji),
            isIncome: category.direction == .income
        )
    }
    
    func toCategory() -> Category {
        Category(
            id: id,
            name: name,
            emoji: emoji.first ?? "❓",
            direction: isIncome ? .income : .outcome
        )
    }
}
