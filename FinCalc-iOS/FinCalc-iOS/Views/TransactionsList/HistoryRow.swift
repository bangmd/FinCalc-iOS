//
//  HistoryRow.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 20.06.2025.
//

import SwiftUI

struct HistoryRow: View {
    let transaction: TransactionResponse
    let onTap: () -> Void
    @State private var showEdit = false
    
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
        .onTapGesture {
            onTap()
        }
    }
}
