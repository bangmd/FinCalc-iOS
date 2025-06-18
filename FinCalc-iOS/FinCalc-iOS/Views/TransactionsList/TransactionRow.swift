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
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(.lightGreen))
                    .frame(width: 22, height: 22)
                Text("\(transaction.category.emoji)")
                    .font(.system(size: 14))
                    .frame(alignment: .center)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category.name)
                    .font(.system(size: 17))
                    .foregroundColor(.black)
                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Text("\(Decimal(string: transaction.amount) ?? 0) ₽")
                .font(.system(size: 17))
                .foregroundColor(.black)
            Image(systemName: "chevron.right")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(.systemGray3))
        }
    }
}
