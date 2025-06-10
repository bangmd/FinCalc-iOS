//
//  Category.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import Foundation

enum Direction: Decodable {
    case income
    case outcome
}

struct Category: Decodable {
    let id: Int
    let name: String
    let emoji: Character
    let direction: Direction

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case emoji
        case isIncome
    }

    init(id: Int, name: String, emoji: Character, direction: Direction) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.direction = direction
    }

    init(from decoder: Decoder ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let emojiString = try container.decode(String.self, forKey: .emoji)
        emoji = emojiString.first ?? "❌"
        let isIncome = try container.decode(Bool.self, forKey: .isIncome)
        direction = isIncome ? .income : .outcome
    }
}
