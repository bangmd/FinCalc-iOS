//
//  DailyBalance.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 20.07.2025.
//

import Foundation

struct DailyBalance: Identifiable {
    let id = UUID()
    let date: Date
    let balance: Decimal
}
