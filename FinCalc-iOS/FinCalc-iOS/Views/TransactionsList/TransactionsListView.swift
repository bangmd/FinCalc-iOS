//
//  TransactionsListView.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    private let direction: Direction
    private let dependencies: AppDependencies
    @StateObject private var viewModel: TransactionsListViewModel
    @State private var isPresentingEditor = false
    @State private var selectedTransaction: TransactionResponse? = nil
    @State private var isPresentingCreate = false
    @State private var showAlert = false

    init(direction: Direction, dependencies: AppDependencies) {
        self.dependencies = dependencies
        self.direction = direction
        _viewModel = StateObject(wrappedValue: TransactionsListViewModel(service: dependencies.transactionsService))
    }
    
    var body: some View {
        VStack {
            headerView
            totalAmountView
            operationsListView
        }
        .task {
            await viewModel.loadTransactions(for: direction)
        }
        .padding(.horizontal, Constants.horizontalPadding)
        .padding(.vertical, Constants.verticalPadding)
        .background(Color(.systemGray6).ignoresSafeArea())
        .fullScreenCover(isPresented: $isPresentingCreate) {
            EditTransactionView(
                mode: .create,
                direction: direction,
                transactionsService: dependencies.transactionsService,
                bankAccountsService: dependencies.bankAccountsService
            ) {
                isPresentingCreate = false
                Task { await viewModel.loadTransactions(for: direction) }
            }
        }
        .fullScreenCover(item: $selectedTransaction) { transaction in
            EditTransactionView(
                mode: .edit(transaction),
                direction: direction,
                transactionsService: dependencies.transactionsService,
                bankAccountsService: dependencies.bankAccountsService
            ) {
                print("onComplete в TransactionsListView")

                selectedTransaction = nil
                Task { await viewModel.loadTransactions(for: direction) }
            }
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
        .overlay {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView("Загрузка...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground)))
                        .shadow(radius: 6)
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            plusButton
                .padding()
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack {
            historyButton
            titleView
        }
    }
    
    private var historyButton: some View {
        HStack {
            Spacer()
            NavigationLink(destination: TransactionsHistoryView(direction: direction)) {
                Image(systemName: "clock")
                    .font(.system(size: Constants.historyIconSize))
                    .foregroundColor(Color(.purpleForButton))
            }
        }
    }
    
    private var titleView: some View {
        HStack {
            Text(direction == .outcome ? "today_outcomes" : "today_incomes")
                .font(.largeTitle)
                .bold()
            Spacer()
        }
    }
    
    // MARK: - Total Amount View
    private var totalAmountView: some View {
        HStack {
            Text("total_label")
                .fontWeight(.regular)
                .padding(.leading, Constants.horizontalPadding)
            Spacer()
            Text(viewModel.totalAmount.formatted(currencyCode: CurrencyStore.shared.currentCurrency))
                .fontWeight(.regular)
                .padding(.trailing, Constants.horizontalPadding)
        }
        .frame(height: Constants.totalViewHeight)
        .background(Color(.systemBackground))
        .cornerRadius(Constants.cornerRadius)
    }
    
    // MARK: - Operations
    @ViewBuilder
    private var operationsListView: some View {
        if viewModel.transactions.isEmpty {
            emptyStateView
        } else {
            transactionsListView
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Text(direction == .outcome ? "💸" : "💰")
                .font(.system(size: Constants.emptyStateEmojiSize))
            Text(direction == .outcome ? "no_outcomes" : "no_incomes")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, Constants.emptyStateTopPadding)
    }
    
    private var transactionsListView: some View {
        VStack(spacing: 0) {
            Text("operations_header")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, Constants.headerPaddingVertical)
                .padding(.horizontal)
                .padding(.bottom, Constants.bottomPaddingForHedder)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(viewModel.transactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRow(transaction: transaction)
                            .padding(.vertical, Constants.rowVerticalPadding)
                            .padding(.horizontal, Constants.rowHorizontalPadding)
                            .frame(height: Constants.totalViewHeight)
                            .background(Color(.systemBackground))
                            .clipShape(
                                RoundedCorner(
                                    radius: Constants.cornerRadius,
                                    corners: viewModel.transactions.count == 1 ? .allCorners :
                                        index == 0 ? [.topLeft, .topRight] :
                                        index == viewModel.transactions.count - 1 ? [.bottomLeft, .bottomRight] :
                                        []
                                )
                            )
                            .onTapGesture {
                                selectedTransaction = transaction
                            }
                        if index != viewModel.transactions.count - 1 {
                            Divider()
                                .padding(.leading, Constants.dividerIndent)
                        }
                    }
                }
            }
        }
    }
    
    private var plusButton: some View {
        HStack {
            Spacer()
            Button {
                isPresentingCreate = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: Constants.plusIconSize))
                    .foregroundColor(.white)
                    .frame(
                        width: Constants.plusButtonSize,
                        height: Constants.plusButtonSize
                    )
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    TransactionsListView(direction: .outcome, dependencies: AppDependencies())
}
