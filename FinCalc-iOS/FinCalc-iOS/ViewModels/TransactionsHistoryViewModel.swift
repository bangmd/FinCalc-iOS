//
//  TransactionsHistoryViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 19.06.2025.
//

import Foundation

@MainActor
final class TransactionsHistoryViewModel: ObservableObject {
    // MARK: - Published State
    @Published var transactions: [TransactionResponse] = []
    @Published var totalAmount: Decimal = 0
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    // MARK: - Date Range
    @Published var fromDate: Date {
        didSet {
            if fromDate > toDate {
                toDate = fromDate
            }
            Task { await loadTransactions() }
        }
    }
    @Published var toDate: Date {
        didSet {
            if toDate < fromDate {
                fromDate = toDate
            }
            Task { await loadTransactions() }
        }
    }

    // MARK: - Configuration
    let direction: Direction
    private let accountId: Int
    private let service: TransactionsServiceProtocol

    // MARK: - Initialization
    init(
        direction: Direction,
        accountId: Int = 1,
        service: TransactionsServiceProtocol = TransactionsService()
    ) {
        self.direction = direction
        self.accountId = accountId
        self.service = service

        let now = Date()
        let calendar = Calendar.current

        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        self.fromDate = calendar.startOfDay(for: oneMonthAgo)

        if let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) {
            self.toDate = endOfDay
        } else {
            self.toDate = calendar.startOfDay(for: now)
        }
    }

    // MARK: - Public API

    func loadTransactions() async {
        isLoading = true
        defer { isLoading = false }

        guard let (startOfDay, endOfDay) = makeBoundaryDates() else {
            errorMessage = "Не удалось вычислить границы периода"
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
            let filtered = filterByDirection(all)
            transactions = filtered
            totalAmount = computeTotal(filtered)
            errorMessage = nil
        } catch {
            transactions = []
            totalAmount = 0
            errorMessage = error.localizedDescription
        }
    }

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
}
