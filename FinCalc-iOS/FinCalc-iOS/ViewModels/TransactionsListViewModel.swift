//
//  TransactionsListViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.06.2025.
//

import Foundation

final class TransactionsListViewModel: ObservableObject {
    @MainActor @Published var isLoading: Bool = false
    @MainActor @Published var errorMessage: String?

    @MainActor  @Published var transactions: [TransactionResponse] = []
    @MainActor @Published var totalAmount: Decimal = 0

    private let service: TransactionsServiceProtocol
    private let accountId: Int

    init(
        service: TransactionsServiceProtocol = TransactionsService(),
        accountId: Int = 1
    ) {
        self.service = service
        self.accountId = accountId
    }

    @MainActor
    func loadTransactions(for direction: Direction) async {
        isLoading = true
        defer { isLoading = false }

        let today = Date()
        let startOfDay = Calendar.current.startOfDay(for: today)
        guard let endOfDay = Calendar.current.date(
            bySettingHour: 23,
            minute: 59,
            second: 59,
            of: today
        ) else {
            errorMessage = "error_failed_compute_end_of_day"
            return
        }

        let startDateString = DateFormatters.iso8601.string(from: startOfDay)
        let endDateString = DateFormatters.iso8601.string(from: endOfDay)

        do {
            let responses = try await service.fetchTransactions(
                accountId: accountId,
                startDate: startDateString,
                endDate: endDateString
            )

            let filteredResponses = responses.filter {
                $0.category.direction == direction
            }

            self.transactions = filteredResponses
            self.totalAmount = filteredResponses.reduce(0) {
                $0 + (Decimal(string: $1.amount) ?? 0)
            }
            self.errorMessage = nil
        } catch {
            self.transactions = []
            self.totalAmount = 0
            self.errorMessage = error.localizedDescription
        }
    }
}
