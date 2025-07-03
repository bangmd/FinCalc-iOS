//
//  HistoryRow.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 20.06.2025.
//

import SwiftUI

struct HistoryRow: View {
    let transaction: TransactionResponse
    var body: some View {
        HStack(spacing: Constants.rowHorizontalPadding) {
            if transaction.category.direction == .outcome {
                ZStack {
                    Circle()
                        .fill(Color(.lightGreen))
                        .frame(
                            width: Constants.categoryIconSize,
                            height: Constants.categoryIconSize
                        )
                    Text("\(transaction.category.emoji)")
                        .font(.system(size: Constants.emojiFontSize))
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.name)
                    .font(.system(size: Constants.primaryFontSize))
                    .foregroundColor(.primary)
                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: Constants.secondaryFontSize))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                let amount = Decimal(string: transaction.amount) ?? .zero
                Text(amount.formatted(currencyCode: transaction.account.currency))
                    .font(.system(size: Constants.primaryFontSize))
                    .foregroundColor(.primary)
                if let date = DateFormatters.iso8601.date(from: transaction.updatedAt) {
                    Text(DateFormatters.hhmmUTC.string(from: date))
                        .font(.system(size: Constants.secondaryFontSize))
                        .foregroundColor(.primary)
                }
            }
            Image(systemName: "chevron.right")
                .font(.system(
                    size: Constants.chevronFontSize,
                    weight: .bold
                ))
                .foregroundColor(Color(.systemGray3))
        }
    }
}

#Preview {
    HistoryRow(transaction: TransactionResponse(
        id: 1,
        account: AccountBrief(id: 1, name: "Main", balance: "1000.00", currency: "RUB"),
        category: Category(id: 1, name: "Test", emoji: "🛠", direction: .outcome),
        amount: "123.45",
        transactionDate: "2025-06-20T22:01:00.000Z",
        comment: "Sample comment",
        createdAt: "",
        updatedAt: "2025-06-20T21:01:00.000Z"
    ))
}
