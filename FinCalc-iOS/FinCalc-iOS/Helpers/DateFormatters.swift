//
//  DateFormatters.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import Foundation

enum DateFormatters {
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}
