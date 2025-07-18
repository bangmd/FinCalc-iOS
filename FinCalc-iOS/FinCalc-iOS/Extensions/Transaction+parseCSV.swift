//
//  Transaction+parseCSV.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 13.06.2025.
//

import Foundation

// MARK: - CSV Conversion
extension Transaction {
    var csvLine: String {
        [
            "\(id)",
            "\(accountId)",
            "\(categoryId)",
            "\(amount)",
            transactionDate,
            comment ?? "",
            createdAt,
            updatedAt
        ].joined(separator: ",")
    }

    private enum CSVField: Int {
        case id = 0, accountId, categoryId, amount, transactionDate, comment, createdAt, updatedAt
    }

    static func fromCSV(_ csv: String) -> Transaction? {
        let components = csv.components(separatedBy: ",")
        guard components.count > CSVField.updatedAt.rawValue else { return nil }

        let idString = components[CSVField.id.rawValue].trimmingCharacters(in: .whitespaces)
        let accountIdString = components[CSVField.accountId.rawValue]
        let categoryIdString = components[CSVField.categoryId.rawValue]
        let amount = components[CSVField.amount.rawValue]
        let transactionDate = components[CSVField.transactionDate.rawValue]
        let commentString = components[CSVField.comment.rawValue]
        let createdAt = components[CSVField.createdAt.rawValue]
        let updatedAt = components[CSVField.updatedAt.rawValue]

        guard
            let id = Int(idString),
            let accountId = Int(accountIdString),
            let categoryId = Int(categoryIdString)
        else {
            return nil
        }

        let comment = commentString.isEmpty ? nil : commentString

        return Transaction(
            id: id,
            accountId: accountId,
            categoryId: categoryId,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    static func fromCSVFile(_ csv: String) -> [Transaction] {
        let lines = csv.components(separatedBy: .newlines).filter { !$0.isEmpty }
        return lines.compactMap { Transaction.fromCSV($0) }
    }
}
