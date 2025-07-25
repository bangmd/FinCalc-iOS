//
//  TransactionsHistoryViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 19.06.2025.
//

import Foundation

final class TransactionsHistoryViewModel: ObservableObject {
    // MARK: - Published State
    @MainActor @Published var transactions: [TransactionResponse] = []
    @MainActor @Published var totalAmount: Decimal = 0
    @MainActor @Published var errorMessage: String?
    @MainActor @Published var isLoading: Bool = false

    // MARK: - Date Range
    @MainActor @Published var fromDate: Date {
        didSet {
            if fromDate > toDate {
                toDate = fromDate
            }
            Task { await loadTransactions() }
        }
    }

    @MainActor @Published var toDate: Date {
        didSet {
            if toDate < fromDate {
                fromDate = toDate
            }
            Task { await loadTransactions() }
        }
    }

    @MainActor @Published var sortOption: SortOption = .dateDesc {
        didSet { Task { await loadTransactions() } }
    }

    // MARK: - Configuration
    let direction: Direction
    private let accountId: Int
    private let service: TransactionsServiceProtocol

    // MARK: - Initialization
    @MainActor
    init(
        direction: Direction,
        accountId: Int = CurrencyStore.shared.currentAccountId,
        service: TransactionsServiceProtocol
    ) {
        self.direction = direction
        self.accountId = accountId
        self.service = service

        let now = Date()
        let calendar = Calendar.current

        let oneMonthAgo = calendar.date(
            byAdding: .month,
            value: -1,
            to: now
        ) ?? now
        self.fromDate = calendar.startOfDay(for: oneMonthAgo)

        if let endOfDay = calendar.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: now
        ) {
            self.toDate = endOfDay
        } else {
            self.toDate = calendar.startOfDay(for: now)
        }
    }

    // MARK: - Loading data
    @MainActor
    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }

        guard let (startOfDay, endOfDay) = makeBoundaryDates() else {
            errorMessage = "error_failed_compute_period_boundaries"
            transactions = []
            totalAmount = 0
            return
        }

        let startString = DateFormatters.iso8601.string(from: startOfDay)
        let endString   = DateFormatters.iso8601.string(from: endOfDay)

        do {
            let all = try await service.fetchTransactions(
                accountId: accountId,
                startDate: startString,
                endDate: endString
            )
            var list = filterByDirection(all)
            sort(&list)
            transactions = list
            totalAmount  = computeTotal(list)
            errorMessage = nil
        } catch {
            transactions = []
            totalAmount = 0
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func makeBoundaryDates() -> (Date, Date)? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: fromDate)
        guard let end = calendar.date(
            bySettingHour: 23, minute: 59, second: 59,
            of: toDate
        ) else { return nil }
        return (start, end)
    }

    private func filterByDirection(_ list: [TransactionResponse]) -> [TransactionResponse] {
        list.filter { $0.category.direction == direction }
    }

    private func computeTotal(_ list: [TransactionResponse]) -> Decimal {
        list.reduce(0) { $0 + (Decimal(string: $1.amount) ?? 0) }
    }

    @MainActor
    private func sort(_ list: inout [TransactionResponse]) {
        switch sortOption {
        case .dateDesc:
            list.sort { $0.date > $1.date }
        case .dateAsc:
            list.sort { $0.date < $1.date }
        case .amountDesc:
            list.sort {
                ($0.decimalAmount, $0.id) > ($1.decimalAmount, $1.id)
            }
        case .amountAsc:
            list.sort {
                ($0.decimalAmount, $0.id) < ($1.decimalAmount, $1.id)
            }
        }
    }
}
