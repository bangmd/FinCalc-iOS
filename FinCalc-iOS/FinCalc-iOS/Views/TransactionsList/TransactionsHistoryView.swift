//
//  TransactionsHistoryView.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 19.06.2025.
//

import SwiftUI

struct TransactionsHistoryView: View {
    let direction: Direction
    @StateObject private var viewModel: TransactionsHistoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var selectedTransaction: TransactionResponse?
    
    init(direction: Direction) {
        let dependencies = AppDependencies()
        self.direction = direction
        _viewModel = StateObject(
            wrappedValue: TransactionsHistoryViewModel(
                direction: direction,
                service: dependencies.transactionsService
            )
        )
    }
    
    // MARK: - Subviews
    private var periodSection: some View {
        Section {
            dateRow(label: "history_start", selection: $viewModel.fromDate)
            dateRow(label: "history_end", selection: $viewModel.toDate)
            HStack {
                Text("sort_title")
                    .font(.body)
                Spacer()
                sortMenu
            }
            HStack {
                Text("sum_title")
                    .font(.body)
                Spacer()
                Text(
                    viewModel.totalAmount
                        .formatted(currencyCode: CurrencyStore.shared.currentCurrency)
                )
            }
        }
    }
    
    @ViewBuilder
    private func dateRow(label: String, selection: Binding<Date>) -> some View {
        HStack {
            Text(LocalizedStringKey(label))
                .font(.body)
            Spacer()
            DatePicker("", selection: selection, displayedComponents: [.date])
                .labelsHidden()
                .background(Color(.lightGreen))
                .cornerRadius(Constants.cornerRadius)
        }
    }
    
    // MARK: - Operations Section
    private var operationsSection: some View {
        Section {
            if viewModel.transactions.isEmpty {
                VStack(spacing: 12) {
                    Text(direction == .outcome ? "💸" : "💰")
                        .font(.system(size: Constants.plusButtonSize))
                    Text(direction == .outcome
                         ? "no_outcomes"
                         : "no_incomes")
                    .font(.headline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, Constants.plusButtonSize)
            } else {
                ForEach(viewModel.transactions) { transaction in
                    HistoryRow(
                        transaction: transaction,
                        onTap: {
                            selectedTransaction = transaction
                        }
                    )
                }
            }
        } header: {
            if !viewModel.transactions.isEmpty {
                HStack {
                    Text("operations_header")
                        .font(.system(size: Constants.secondaryFontSize))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Sort Picker
    private var sortMenu: some View {
        Menu {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    viewModel.sortOption = option
                } label: {
                    if option == viewModel.sortOption {
                        Label(option.titleKey, systemImage: "checkmark")
                    } else {
                        Text(option.titleKey)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.sortOption.titleKey)
                Image(systemName: "chevron.down")
            }
            .font(.body)
            .foregroundColor(.primary)
        }
    }
    
    var body: some View {
        ZStack {
            List {
                periodSection
                operationsSection
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
            }
        }
        .navigationTitle("history_title")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    AnalysisViewControllerWrapper(
                        direction: direction,
                        fromDate: viewModel.fromDate,
                        toDate: viewModel.toDate
                    )
                    .background(Color(.systemGray6).ignoresSafeArea(edges: .all))
                } label: {
                    Image(systemName: "document")
                        .tint(Color(.purpleForButton))
                }
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .task {
            await viewModel.loadTransactions()
        }
        .onChange(of: viewModel.errorMessage) {
            showAlert = viewModel.errorMessage != nil
        }
        .alert("Ошибка", isPresented: $showAlert) {
            Button("Ок") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .fullScreenCover(item: $selectedTransaction) { transaction in
            let dependencies = AppDependencies()
            EditTransactionView(
                mode: .edit(transaction),
                direction: transaction.category.direction,
                transactionsService: dependencies.transactionsService,
                bankAccountsService: dependencies.bankAccountsService
            ) {
                selectedTransaction = nil
                Task { await viewModel.loadTransactions() }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TransactionsHistoryView(direction: .outcome)
    }
}
