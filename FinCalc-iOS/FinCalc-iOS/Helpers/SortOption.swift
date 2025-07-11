//
//  SortOption.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 21.06.2025.
//

import SwiftUI

enum SortOption: String, CaseIterable {
    case dateDesc
    case dateAsc
    case amountDesc
    case amountAsc

    var titleKey: LocalizedStringKey {
        switch self {
        case .dateDesc: "sort_date_desc"
        case .dateAsc: "sort_date_asc"
        case .amountDesc: "sort_amount_desc"
        case .amountAsc: "sort_amount_asc"
        }
    }
    
    var localizedTitle: String {
        let key: String
        switch self {
        case .dateDesc:   key = "sort_date_desc"
        case .dateAsc:    key = "sort_date_asc"
        case .amountDesc: key = "sort_amount_desc"
        case .amountAsc:  key = "sort_amount_asc"
        }
        return NSLocalizedString(key, comment: "")
    }
}
