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

    var body: some View {
        VStack {
            headerView
            totalAmountView
            Text("ОПЕРАЦИИ")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 12)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            operationsListView
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
                .padding(.trailing, 16)
            }
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
                Button {
                    //TODO: Действие по нажатию
                } label: {
                    Image(systemName: "clock")
                        .foregroundColor(Color(.purpleForButton))
                }
                .frame(width: 26, height: 22)
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
            Text("\(viewModel.totalAmount) ₽")
                .fontWeight(.regular)
                .padding(.trailing, 16)
        }
        .frame(height: 44)
        .background(Color.white)
        .cornerRadius(10)
    }

    // MARK: - Operations List View
    private var operationsListView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                let cellCorner: CGFloat = 16
                ForEach(Array(viewModel.transactions.enumerated()), id: \.element.id) { index, transaction in
                    TransactionRow(transaction: transaction)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
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

#Preview {
    TransactionsListView(direction: .income)
}
