//
//  ExpensesRow.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 03.07.2025.
//

import SwiftUI

struct ExpensesRow: View {
    let category: Category
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(.lightGreen))
                    .frame(width: Constants.categoryIconSize, height: Constants.categoryIconSize)
                Text("\(category.emoji)")
                    .font(.system(size: Constants.emojiFontSize))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .font(.system(size: Constants.primaryFontSize))
                    .foregroundColor(.black)
            }
            Spacer()
        }
    }
}
