//
//  Decimal.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 19.06.2025.
//

import Foundation

extension Decimal {
    func formatted(currencyCode: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        formatter.locale = Locale(identifier: "ru_RU")

        let number = NSDecimalNumber(decimal: self)
        let amountString = formatter.string(from: number) ?? "\(self)"

        let currencySymbol: String
        switch currencyCode {
        case "RUB": currencySymbol = "₽"
        case "USD": currencySymbol = "$"
        case "EUR": currencySymbol = "€"
        default: currencySymbol = currencyCode
        }

        return "\(amountString) \(currencySymbol)"
    }
}
