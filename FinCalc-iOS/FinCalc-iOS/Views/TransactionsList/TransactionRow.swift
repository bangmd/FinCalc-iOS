//
//  TransactionRow.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.06.2025.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: TransactionResponse
    var body: some View {
        HStack(spacing: 16) {
            if transaction.category.direction == .outcome {
                ZStack {
                    Circle()
                        .fill(Color(.lightGreen))
                        .frame(width: Constants.categoryIconSize, height: Constants.categoryIconSize)
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
            let amount = Decimal(string: transaction.amount) ?? .zero
            Text(amount.formatted(currencyCode: transaction.account.currency))
                .font(.system(size: Constants.primaryFontSize))
                .foregroundColor(.primary)
            Image(systemName: "chevron.right")
                .font(.system(size: Constants.chevronFontSize, weight: .bold))
                .foregroundColor(Color(.systemGray3))
        }
    }
}
