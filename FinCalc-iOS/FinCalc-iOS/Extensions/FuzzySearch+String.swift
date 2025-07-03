//
//  FuzzySearch+String.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 03.07.2025.
//

import Foundation

extension String {
    func fuzzyMatches(_ search: String) -> Bool {
        if search.isEmpty { return true }
        var searchIndex = search.startIndex
        for char in self.lowercased()
        where String(search[searchIndex]).lowercased() == String(char).lowercased() {
            search.formIndex(after: &searchIndex)
            if searchIndex == search.endIndex { return true }
        }
        return false
    }
}
