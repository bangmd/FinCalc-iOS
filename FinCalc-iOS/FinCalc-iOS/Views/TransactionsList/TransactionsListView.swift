//
//  TransactionsListView.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    let direction: Direction
    @StateObject private var viewModel = TransactionsListViewModel()
    @State private var isHistoryActive = false

    var body: some View {
        VStack {
            headerView
            totalAmountView
            operationsListView
            plusButton
        }
        .task {
            await viewModel.loadTransactions(for: direction)
        }
        .padding(.horizontal, 16)
        .padding(.vertical)
        .background(Color(.systemGray6).ignoresSafeArea())
    }

    // MARK: - Header View
    private var headerView: some View {
        VStack {
            HStack {
                Spacer()
                NavigationLink(destination: TransactionsHistoryView(direction: direction)) {
                    Image(systemName: "clock")
                        .font(.system(size: 22))
                        .foregroundColor(Color(.purpleForButton))
                }
            }
            HStack {
                Text(direction == .outcome ? "Расходы сегодня" : "Доходы сегодня")
                    .font(.largeTitle)
                    .bold()
                Spacer()
            }
        }
    }

    // MARK: - Total Amount View
    private var totalAmountView: some View {
        HStack {
            Text("Всего")
                .fontWeight(.regular)
                .padding(.leading, 16)
            Spacer()
            Text(viewModel.totalAmount.formatted(currencyCode: "RUB"))
                .fontWeight(.regular)
                .padding(.trailing, 16)
        }
        .frame(height: 44)
        .background(Color.white)
        .cornerRadius(10)
    }

    // MARK: - Operations List View
    @ViewBuilder
    private var operationsListView: some View {
        if viewModel.transactions.isEmpty {
            VStack(spacing: 12) {
                Text(direction == .outcome ? "💸" : "💰")
                    .font(.system(size: 56))
                Text(direction == .outcome ? "Сегодня нет расходов" : "Сегодня нет доходов")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 32)
        } else {
            VStack {
                Text("ОПЕРАЦИИ")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 12)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                ScrollView {
                    LazyVStack(spacing: 0) {
                        let cellCorner: CGFloat = 10
                        ForEach(Array(viewModel.transactions.enumerated()), id: \.element.id) { index, transaction in
                            TransactionRow(transaction: transaction)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .frame(height: 44)
                                .background(Color.white)
                                .clipShape(
                                    RoundedCorner(
                                        radius: cellCorner,
                                        corners:
                                            viewModel.transactions.count == 1 ? .allCorners :
                                            index == 0 ? [.topLeft, .topRight] :
                                            index == viewModel.transactions.count - 1 ? [.bottomLeft, .bottomRight] :
                                            []
                                    )
                                )
                            if index != viewModel.transactions.count - 1 {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Plus Button
    private var plusButton: some View {
        HStack {
            Spacer()
            Button {
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
        }
    }
}

#Preview {
    TransactionsListView(direction: .income)
}
