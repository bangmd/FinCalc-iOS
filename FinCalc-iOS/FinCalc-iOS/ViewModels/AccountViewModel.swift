//
//  AccountViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 25.06.2025.
//

import Foundation

final class AccountViewModel: ObservableObject {
    private let service: BankAccountsServiceProtocol

    init(service: BankAccountsServiceProtocol) {
        self.service = service
    }

    // MARK: - Published-свойства для UI
    @Published var account: Account?
    @Published var balance: Decimal = 0
    @Published var currency: Currency = .rub
    @Published var name: String = ""
    @Published var isEditing = false
    @Published var showCurrencyPicker = false

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
            }
            self.name = loaded?.name ?? ""
        } catch {
            print("Ошибка загрузки аккаунта: \(error)")
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
