//
//  CategoriesService.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.06.2025.
//

import Foundation
protocol CategoriesServiceProtocol {
    func getAllCategories() async throws -> [Category]
}

final class CategoriesService: CategoriesServiceProtocol {
    // MARK: - Properties
    private let mockCategories: [Category] = [
        Category(id: 1, name: "Аренда квартиры", emoji: "🏠", direction: .outcome),
        Category(id: 2, name: "Одежда", emoji: "👔", direction: .outcome),
        Category(id: 3, name: "Зарплата", emoji: "💸", direction: .income),
        Category(id: 4, name: "Получение дивидендов", emoji: "📈", direction: .income),
        Category(id: 5, name: "Продукты", emoji: "🍬", direction: .outcome),
        Category(id: 6, name: "Транспорт", emoji: "🚗", direction: .outcome),
        Category(id: 7, name: "Здоровье", emoji: "💊", direction: .outcome),
        Category(id: 8, name: "Образование", emoji: "🎓", direction: .outcome),
        Category(id: 9, name: "Подарки", emoji: "🎁", direction: .outcome),
        Category(id: 10, name: "Инвестиции", emoji: "💹", direction: .outcome),
        Category(id: 11, name: "Ремонт", emoji: "🔨", direction: .outcome),
        Category(id: 12, name: "Спорт", emoji: "🤸‍♂️", direction: .outcome),
        Category(id: 13, name: "Отпуск", emoji: "🏖️", direction: .outcome),
        Category(id: 14, name: "Связь и интернет", emoji: "📱", direction: .outcome),
        Category(id: 15, name: "Ресторан", emoji: "🍽️", direction: .outcome),
        Category(id: 16, name: "Фриланс", emoji: "💻", direction: .income),
        Category(id: 17, name: "Проценты по вкладам", emoji: "🏦", direction: .income),
        Category(id: 18, name: "Продажа вещей", emoji: "🛍️", direction: .income),
        Category(id: 19, name: "Кэшбэк", emoji: "🎉", direction: .income),
        Category(id: 20, name: "Премия", emoji: "🏆", direction: .income)
    ]

    // MARK: - Methods
    func getAllCategories() async throws -> [Category] {
        return mockCategories
    }

    func getCategoriesByType(direction: Direction) async throws -> [Category] {
        return mockCategories.filter { $0.direction == direction }
    }
}
