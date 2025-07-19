//
//  AnalysisViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.07.2025.
//

import Foundation
import PieChart

final class AnalysisViewModel {
    // MARK: - State
    var transactions: [TransactionResponse] = []
    var shareById: [Int: Decimal] = [:]
    var totalAmount: Decimal = 0
    var isLoading: Bool = false
    var errorMessage: String?
    
    var onDataChanged: (() -> Void)?
    
    // MARK: - Period
    var fromDate: Date {
        didSet {
            if fromDate > toDate {
                toDate = fromDate
            }
            Task { await loadTransactions() }
        }
    }
    var toDate: Date {
        didSet {
            if toDate < fromDate {
                fromDate = toDate
            }
            Task { await loadTransactions() }
        }
    }
    
    // MARK: - Сортировка
    var sortOption: SortOption = .dateDesc {
        didSet {
            Task { await loadTransactions() }
        }
    }
    
    // MARK: - Конфигурация
    let direction: Direction
    private var accountId: Int {
        CurrencyStore.shared.currentAccountId
    }
    private let service: TransactionsServiceProtocol
    
    // MARK: - Инициализация
    init(
        direction: Direction,
        fromDate: Date,
        toDate: Date,
        service: TransactionsServiceProtocol
    ) {
        self.direction = direction
        self.service = service
        self.fromDate = Calendar.current.startOfDay(for: fromDate)
        self.toDate = Calendar.current.date(
            bySettingHour: 23, minute: 59, second: 59, of: toDate
        ) ?? Calendar.current.startOfDay(for: toDate)
    }
    
    // MARK: - Загрузка операций
    @MainActor
    func loadTransactions() async {
        self.isLoading = true
        
        guard let (startOfDay, endOfDay) = makeBoundaryDates() else {
            errorMessage = "Ошибка периода"
            transactions = []
            totalAmount = 0
            self.isLoading = false
            await MainActor.run {
                self.onDataChanged?()
            }
            return
        }
        
        let startString = DateFormatters.iso8601.string(from: startOfDay)
        let endString = DateFormatters.iso8601.string(from: endOfDay)
        
        do {
            let all = try await service.fetchTransactions(
                accountId: accountId,
                startDate: startString,
                endDate: endString
            )
            var filtered = filterByDirection(all)
            sort(&filtered)
            transactions = filtered
            await MainActor.run {
                self.onDataChanged?()
            }
            totalAmount = computeTotal(filtered)
            shareById = calculateShares(for: filtered)
            errorMessage = nil
        } catch {
            transactions = []
            totalAmount = 0
            errorMessage = error.localizedDescription
        }
        self.isLoading = false
    }
    
    private func makeBoundaryDates() -> (Date, Date)? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: fromDate)
        guard let end = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: toDate) else {
            return nil
        }
        return (start, end)
    }
    
    private func filterByDirection(_ list: [TransactionResponse]) -> [TransactionResponse] {
        list.filter { $0.category.direction == direction }
    }
    
    private func computeTotal(_ list: [TransactionResponse]) -> Decimal {
        list.reduce(0) { $0 + (Decimal(string: $1.amount) ?? 0) }
    }
    
    private func sort(_ list: inout [TransactionResponse]) {
        switch sortOption {
        case .dateDesc:
            list.sort { $0.date > $1.date }
        case .dateAsc:
            list.sort { $0.date < $1.date }
        case .amountDesc:
            list.sort { ($0.decimalAmount, $0.id) > ($1.decimalAmount, $1.id) }
        case .amountAsc:
            list.sort { ($0.decimalAmount, $0.id) < ($1.decimalAmount, $1.id) }
        }
    }
    
    private func calculateShares(for list: [TransactionResponse]) -> [Int: Decimal] {
        guard totalAmount != 0 else { return [:] }
        var result: [Int: Decimal] = [:]
        for transaction in list {
            let amount = Decimal(string: transaction.amount) ?? 0
            result[transaction.id] = (amount / totalAmount) * 100
        }
        return result
    }
    
    // MARK: - API для ViewController
    func makePieEntities() -> [Entity] {
        let grouped = Dictionary(grouping: transactions) { $0.category.name }
        let entities = grouped.map { (label, trs) in
            Entity(
                value: trs.reduce(Decimal(0)) { $0 + (Decimal(string: $1.amount) ?? 0) },
                label: label
            )
        }
        return entities.sorted { $0.value > $1.value }
    }
    
    func updateFromDate(_ date: Date) {
        fromDate = date
    }
    
    func updateToDate(_ date: Date) {
        toDate = date
    }
    
    func updateSortOption(_ option: SortOption) {
        sortOption = option
    }
    
    // MARK: - Helpers
    func share(for transactionID: Int) -> Decimal {
        shareById[transactionID] ?? 0
    }
}
