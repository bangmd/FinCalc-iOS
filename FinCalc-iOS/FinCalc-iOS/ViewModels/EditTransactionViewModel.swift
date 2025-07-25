//
//  EditTransactionViewModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 11.07.2025.
//

import Foundation

// MARK: - EditMode enum
enum EditMode {
    case create
    case edit(TransactionResponse)
}

enum SaveResult {
    case success
    case offlineSaved
    case validationFailed
}

enum DeleteResult {
    case success
    case offlineDeleted
    case validationFailed
}

@MainActor
final class EditTransactionViewModel: ObservableObject {
    @Published var selectedCategory: Category?
    @Published var amount = "" {
        didSet {
            if amount != filteredAmount(amount) {
                amount = filteredAmount(amount)
            }
        }
    }
    @Published var transactionDate = Date()
    @Published var comment: String = ""
    @Published var categories = [Category]()
    @Published var isCategoriesLoading = false
    
    let mode: EditMode
    let direction: Direction
    
    private let transactionsService: TransactionsServiceProtocol
    private let bankAccountsService: BankAccountsServiceProtocol
    
    private var editingTransaction: TransactionResponse?
    
    init(
        mode: EditMode,
        direction: Direction,
        transactionsService: TransactionsServiceProtocol,
        bankAccountsService: BankAccountsServiceProtocol
    ) {
        self.mode = mode
        self.direction = direction
        self.transactionsService = transactionsService
        self.bankAccountsService = bankAccountsService
        
        if case let .edit(transaction) = mode {
            self.selectedCategory = transaction.category
            self.amount = transaction.amount
            self.transactionDate = DateFormatters.parseISO8601(transaction.transactionDate) ?? Date()
            self.comment = transaction.comment ?? ""
            self.editingTransaction = transaction
        }
    }
    
    var isEditing: Bool {
        if case .edit = mode { return true }
        return false
    }
    
    var canSave: Bool {
        selectedCategory != nil && !amount.isEmpty && Double(amount.replacingOccurrences(of: ",", with: ".")) != nil
    }
    
    // MARK: - Actions
    func saveOrCreate(completion: @escaping (SaveResult) -> Void) {
        Task {
            let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)
            let commentValue: String? = trimmedComment.isEmpty ? nil : trimmedComment
            
            guard let selectedCategory = selectedCategory else {
                await MainActor.run { completion(.validationFailed) }
                return
            }
            
            let numericAmount = formattedAmount()
            guard Double(numericAmount) != nil else {
                await MainActor.run { completion(.validationFailed) }
                return
            }
            
            do {
                if isEditing {
                    guard let editing = editingTransaction else {
                        await MainActor.run { completion(.validationFailed) }
                        return
                    }
                    
                    let request = TransactionRequest(
                        accountId: editing.account.id,
                        categoryId: selectedCategory.id,
                        amount: numericAmount,
                        transactionDate: DateFormatters.iso8601.string(from: transactionDate),
                        comment: commentValue
                    )
                    
                    _ = try await transactionsService.updateTransaction(id: editing.id, request: request)
                    await MainActor.run { completion(.success) }
                    
                } else {
                    guard let account = try await bankAccountsService.fetchAccount() else {
                        await MainActor.run { completion(.validationFailed) }
                        return
                    }
                    
                    let request = TransactionRequest(
                        accountId: account.id,
                        categoryId: selectedCategory.id,
                        amount: numericAmount,
                        transactionDate: DateFormatters.iso8601.string(from: transactionDate),
                        comment: commentValue
                    )
                    
                    _ = try await transactionsService.createTransaction(request: request)
                    await MainActor.run { completion(.success) }
                }
            } catch {
                await MainActor.run { completion(.offlineSaved) }
            }
        }
    }
    
    func deleteTransaction(completion: @escaping (DeleteResult) -> Void) {
        guard isEditing, let editing = editingTransaction else {
            completion(.validationFailed)
            return
        }
        Task {
            do {
                try await transactionsService.deleteTransaction(id: editing.id)
                await MainActor.run { completion(.success) }
            } catch {
                await MainActor.run { completion(.offlineDeleted) }
            }
        }
    }
    
    // MARK: - Categories loading
    func loadCategories(categoriesService: CategoriesServiceProtocol) async {
        isCategoriesLoading = true
        do {
            let loaded = try await categoriesService.getCategoriesByType(direction: direction)
            categories = loaded
        } catch {
            categories = []
        }
        isCategoriesLoading = false
    }
    
    private func formattedAmount() -> String {
        amount.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
    }
    
    private var decimalSeparator: String {
        Locale.current.decimalSeparator ?? "."
    }
    
    private func filteredAmount(_ input: String) -> String {
        let separator = Locale.current.decimalSeparator ?? ","
        var result = ""
        var separatorUsed = false
        for char in input {
            if char.isWholeNumber {
                result.append(char)
            } else if char == "." || char == ",", !separatorUsed, !result.isEmpty {
                result.append(separator)
                separatorUsed = true
            }
        }
        return result
    }
}
