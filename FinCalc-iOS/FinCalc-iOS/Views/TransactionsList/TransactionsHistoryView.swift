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

    init(direction: Direction) {
        self.direction = direction
        _viewModel = StateObject(
            wrappedValue: TransactionsHistoryViewModel(direction: direction)
        )
    }

    // MARK: - Subviews
    private var periodSection: some View {
        Section {
            dateRow(label: "Начало", selection: $viewModel.fromDate)
            dateRow(label: "Конец", selection: $viewModel.toDate)
            HStack {
                Text("Сумма")
                    .font(.body)
                Spacer()
                Text(viewModel.totalAmount.formatted(currencyCode: "RUB"))
            }
        }
    }

    @ViewBuilder
    private func dateRow(label: String, selection: Binding<Date>) -> some View {
        HStack {
            Text(label)
                .font(.body)
            Spacer()
            DatePicker("", selection: selection, displayedComponents: [.date])
                .labelsHidden()
                .background(Color(.lightGreen))
                .cornerRadius(6)
        }
    }

    // MARK: - Operations Section
    private var operationsSection: some View {
        Section {
            if viewModel.transactions.isEmpty {
                VStack(spacing: 12) {
                    Text(direction == .outcome ? "💸" : "💰")
                        .font(.system(size: 56))
                    Text(direction == .outcome
                         ? "За выбранный период нет расходов"
                         : "За выбранный период нет доходов")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 32)
            } else {
                ForEach(viewModel.transactions) { transaction in
                    TransactionRow(transaction: transaction)
                }
            }
        } header: {
            if !viewModel.transactions.isEmpty {
                Text("Операции")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
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
        .navigationTitle("Моя история")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: EmptyView()) {
                    Button {
                    } label: {
                        Image(systemName: "document")
                            .tint(Color(.purpleForButton))
                    }
                }
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
        .task {
            await viewModel.loadTransactions()
        }
    }
}

#Preview {
    NavigationStack {
        TransactionsHistoryView(direction: .outcome)
    }
}
