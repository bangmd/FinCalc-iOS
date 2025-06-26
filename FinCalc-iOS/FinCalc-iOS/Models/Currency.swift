//
//  Currency.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 25.06.2025.
//

import Foundation

enum Currency: String, CaseIterable, Identifiable {
    case rub = "₽"
    case usd = "$"
    case eur = "€"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .rub: return "Российский рубль ₽"
        case .usd: return "Американский доллар $"
        case .eur: return "Евро €"
        }
    }
}
