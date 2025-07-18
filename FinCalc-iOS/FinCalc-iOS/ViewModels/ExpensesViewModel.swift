//
//  ExpensesViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 03.07.2025.
//

import Foundation

@MainActor
final class ExpensesViewModel: ObservableObject {
    // MARK: - Published State
    @Published var articles: [Category] = []
    @Published var filteredArticles: [Category] = []
    @Published var searchText: String = "" {
        didSet { filterArticles() }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let service: CategoriesServiceProtocol

    // MARK: - Init
    init(service: CategoriesServiceProtocol) {
        self.service = service
        Task { await loadArticles() }
    }

    // MARK: - Loading data
    func loadArticles() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let loaded = try await service.getAllCategories()
            articles = loaded
            filterArticles()
        } catch {
            errorMessage = error.localizedDescription
            articles = []
            filteredArticles = []
        }
    }

    // MARK: - Filtering (поиск)
    private func filterArticles() {
        guard !searchText.isEmpty else {
            filteredArticles = articles
            return
        }
        filteredArticles = articles.filter {
            $0.name.fuzzyMatches(searchText)
        }
    }
}
