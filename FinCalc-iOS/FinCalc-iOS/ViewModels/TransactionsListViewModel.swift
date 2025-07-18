//
//  TransactionsListViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.06.2025.
//

import Combine
import Network
import Foundation

final class TransactionsListViewModel: ObservableObject {
    @MainActor @Published var isLoading: Bool = false
    @MainActor @Published var errorMessage: String?
    @MainActor  @Published var transactions: [TransactionResponse] = []
    @MainActor @Published var totalAmount: Decimal = 0

    private var cancellables = Set<AnyCancellable>()
    @MainActor @Published var isOfflineMode: Bool = false
    @MainActor @Published var showOfflineBanner: Bool = false

    private let service: TransactionsServiceProtocol

    init(service: TransactionsServiceProtocol) {
        self.service = service

        NetworkMonitor.shared.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                Task { @MainActor in
                    self?.isOfflineMode = !isConnected
                    if !isConnected {
                        self?.showOfflineBanner = true
                        Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 3_000_000_000)
                            self?.showOfflineBanner = false
                        }
                    } else {
                        self?.showOfflineBanner = false
                    }
                }
            }
            .store(in: &cancellables)
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
                accountId: CurrencyStore.shared.currentAccountId,
                startDate: startDateString,
                endDate: endDateString
            )

            let calendar = Calendar.current
            let filteredResponses = responses.filter {
                $0.category.direction == direction &&
                calendar.isDateInToday($0.date)
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
