//
//  AccountViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 25.06.2025.
//

import Foundation

final class AccountViewModel: ObservableObject {
    private let service: BankAccountsServiceProtocol
    private let transactionsService: TransactionsServiceProtocol
    
    @Published var monthlyTransactions: [TransactionResponse] = []
    
    init(
        service: BankAccountsServiceProtocol,
        transactionsService: TransactionsServiceProtocol
    ) {
        self.service = service
        self.transactionsService = transactionsService
    }
    
    // MARK: - Published-свойства для UI
    @Published var account: Account?
    @Published var balance: Decimal = 0
    @Published var currency: Currency = .rub
    @Published var name: String = ""
    @Published var isEditing = false
    @Published var showCurrencyPicker = false
    @Published var transactions: [TransactionResponse] = []
    @Published var dailyBalances: [DailyBalance] = []
    @Published var isChartLoading = false
    
    var monthlyBalances: [DailyBalance] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let months = 24
        
        guard let startMonth = calendar.date(byAdding: .month, value: -months + 1, to: today),
              let normalizedStartMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: startMonth))
        else { return [] }
        
        let monthsRange: [Date] = (0..<months).compactMap { offset in
            calendar.date(byAdding: .month, value: offset, to: normalizedStartMonth)
        }
        
        let grouped = Dictionary(grouping: monthlyTransactions) { trx -> Date in
            guard let month = calendar.date(
                from: calendar.dateComponents([.year, .month], from: trx.date)
            ) else {
                return Date.distantPast
            }
            return month
        }
        return monthsRange.map { monthDate in
            let txs = grouped[monthDate] ?? []
            let monthSum = txs.reduce(Decimal(0)) { sum, trx in
                let value = trx.decimalAmount
                return sum + (trx.category.direction == .income ? value : -value)
            }
            return DailyBalance(date: monthDate, balance: monthSum)
        }
    }
    
    // MARK: - loading account data
    @MainActor
    func loadAccount() async {
        do {
            let loaded = try await service.fetchAccount()
            self.account = loaded
            self.balance = loaded?.balance ?? 0
            self.currency = Currency(rawValue: loaded?.currency ?? "") ?? .rub
            CurrencyStore.shared.currentCurrency = self.currency.rawValue
            if let id = loaded?.id {
                CurrencyStore.shared.currentAccountId = id
                await loadTransactions(accountId: id)
            }
            self.name = loaded?.name ?? ""
        } catch {
            print("Ошибка загрузки аккаунта: \(error)")
        }
    }
    
    @MainActor
    func loadTransactions(accountId: Int) async {
        isChartLoading = true
        defer { isChartLoading = false }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard
            let fromDate = calendar.date(byAdding: .day, value: -29, to: today),
            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: today)
        else {
            print("Ошибка вычисления диапазона дат для загрузки транзакций")
            self.transactions = []
            self.dailyBalances = []
            isChartLoading = false
            return
        }
        let startString = DateFormatters.iso8601.string(from: fromDate)
        let endString = DateFormatters.iso8601.string(from: endOfDay)
        
        do {
            let txs = try await transactionsService.fetchTransactions(
                accountId: accountId,
                startDate: startString,
                endDate: endString
            )
            self.transactions = txs
            self.dailyBalances = Self.calculateDailyDeltas(
                transactions: txs,
                lastNDays: 30
            )
        } catch {
            self.transactions = []
            self.dailyBalances = []
        }
    }
    
    func loadTransactionsForMonths(accountId: Int) async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard
            let fromDate = calendar.date(byAdding: .month, value: -23, to: today),
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: fromDate))
        else {
            print("Ошибка при вычислении дат для загрузки транзакций по месяцам")
            self.monthlyTransactions = []
            return
        }
        
        let startString = DateFormatters.iso8601.string(from: startOfMonth)
        let endString = DateFormatters.iso8601.string(from: today)
        do {
            let txs = try await transactionsService.fetchTransactions(
                accountId: accountId,
                startDate: startString,
                endDate: endString
            )
            self.monthlyTransactions = txs
        } catch {
            print("Ошибка загрузки транзакций по месяцам: \(error)")
            self.monthlyTransactions = []
        }
    }
    
    static func calculateDailyDeltas(
        transactions: [TransactionResponse],
        lastNDays: Int
    ) -> [DailyBalance] {
        let calendar = Calendar.utc
        let today = calendar.startOfDay(for: Date())
        let days = (0..<lastNDays)
            .compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }
            .reversed()
        let grouped = Dictionary(grouping: transactions) { trx in
            calendar.startOfDay(for: trx.date)
        }
        
        var daily: [DailyBalance] = []
        for date in days {
            let txs = grouped[date] ?? []
            let dayDelta = txs.reduce(Decimal(0)) { sum, trx in
                let value = trx.decimalAmount
                return sum + (trx.category.direction == .income ? value : -value)
            }
            daily.append(DailyBalance(date: date, balance: dayDelta))
        }
        return daily
    }
    
    @MainActor
    func refreshAll() async {
        do {
            let loaded = try await service.fetchAccount()
            self.account = loaded
            self.balance = loaded?.balance ?? 0
            self.currency = Currency(rawValue: loaded?.currency ?? "") ?? .rub
            self.name = loaded?.name ?? ""
            CurrencyStore.shared.currentCurrency = self.currency.rawValue
            
            if let id = loaded?.id {
                CurrencyStore.shared.currentAccountId = id
                await loadTransactions(accountId: id)
            } else {
                self.transactions = []
                self.dailyBalances = []
            }
        } catch {
            print("Ошибка обновления аккаунта и транзакций: \(error)")
            self.account = nil
            self.transactions = []
            self.dailyBalances = []
        }
    }
    
    // MARK: - Update data
    @MainActor
    func save() async {
        guard let id = account?.id else { return }
        let request = AccountUpdateRequest(
            name: name,
            balance: balance.description,
            currency: currency.rawValue
        )
        do {
            let updated = try await service.updateAccount(id: id, request: request)
            self.account = updated
            self.balance = updated?.balance ?? 0
            self.currency = Currency(rawValue: updated?.currency ?? "") ?? .rub
            CurrencyStore.shared.currentCurrency = self.currency.rawValue
            if let id = updated?.id {
                CurrencyStore.shared.currentAccountId = id
            }
            self.name = updated?.name ?? ""
            self.isEditing = false
        } catch {
            print("Ошибка обновления аккаунта: \(error)")
        }
    }
    
    func filterBalanceInput(_ input: String) -> String {
        var filtered = input
            .replacingOccurrences(of: ",", with: ".")
            .filter { "0123456789.".contains($0) }
        
        let parts = filtered.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        filtered = parts.prefix(2).joined(separator: ".")
        if parts.count == 2, let decimalPart = parts.last {
            let truncated = String(decimalPart.prefix(2))
            filtered = "\(parts[0]).\(truncated)"
        }
        return filtered
    }
    
    static func preloadAccountInfo(service: BankAccountsServiceProtocol) async {
        do {
            let loaded = try await service.fetchAccount()
            if let id = loaded?.id {
                CurrencyStore.shared.currentAccountId = id
            }
            if let currency = loaded?.currency {
                CurrencyStore.shared.currentCurrency = currency
            }
        } catch {
            print("Ошибка при предварительной загрузке аккаунта: \(error)")
        }
    }
}
