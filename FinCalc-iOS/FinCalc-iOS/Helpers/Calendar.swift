//
//  Calendar.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 20.07.2025.
//

import Foundation

extension Calendar {
    static let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
}
