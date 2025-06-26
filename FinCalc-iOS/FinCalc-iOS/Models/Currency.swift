//
//  Currency.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 25.06.2025.
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case rub = "RUB"
    case usd = "USD"
    case eur = "EUR"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .rub: return "₽"
        case .usd: return "$"
        case .eur: return "€"
        }
    }

    var displayName: String {
        switch self {
        case .rub: return "Российский рубль \(symbol)"
        case .usd: return "Американский доллар \(symbol)"
        case .eur: return "Евро \(symbol)"
        }
    }
}
