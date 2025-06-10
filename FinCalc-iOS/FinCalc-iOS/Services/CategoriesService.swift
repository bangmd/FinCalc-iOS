//
//  CategoriesService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation

final class CategoriesService {
    private let mockCategories: [Category] = [
        Category(id: 1, name: "Аренда квартиры", emoji: "🏠", direction: .outcome),
        Category(id: 2, name: "Одежда", emoji: "👔", direction: .outcome),
        Category(id: 3, name: "Зарплата", emoji: "🐕", direction: .income),
        Category(id: 4, name: "Получение дивидендов", emoji: "🔨", direction: .income),
        Category(id: 5, name: "Продукты", emoji: "🍬", direction: .outcome),
    ]

    func getAllCategories() async throws -> [Category] {
        return mockCategories
    }

    func getCategoriesByType(type: Direction) async throws -> [Category] {
        return mockCategories.filter { $0.direction == type }
    }
}
