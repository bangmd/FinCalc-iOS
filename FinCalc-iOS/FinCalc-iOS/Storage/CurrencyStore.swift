//
//  CurrencyStore.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation

final class CurrencyStore {
    static let shared = CurrencyStore()
    
    private let key = "userCurrencyCode"
    private let accountIdKey = "userAccountId"
    
    private init() {}
    
    var currentCurrency: String {
        get {
            UserDefaults.standard.string(forKey: key) ?? "RUB"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    var currentAccountId: Int {
        get {
            UserDefaults.standard.integer(forKey: accountIdKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: accountIdKey)
        }
    }
    
    func resetToDefault() {
        UserDefaults.standard.removeObject(forKey: key)
    }

    func resetAccountId() {
        UserDefaults.standard.removeObject(forKey: accountIdKey)
    }
    
    func symbol(for code: String) -> String {
        switch code {
        case "RUB": return "₽"
        case "USD": return "$"
        case "EUR": return "€"
        default: return code
        }
    }
}
