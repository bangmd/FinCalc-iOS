//
//  TransactionBackupSDModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation
import SwiftData

@Model
final class TransactionBackupSDModel {
    @Attribute(.unique) var id: Int
    var actionRaw: String
    var transactionData: Data
    
    init(id: Int, action: BackupAction, transaction: TransactionResponse) throws {
        self.id = id
        self.actionRaw = action.rawValue
        self.transactionData = try JSONEncoder().encode(transaction)
    }
    
    var action: BackupAction? {
        BackupAction(rawValue: actionRaw)
    }
    
    var transactionResponse: TransactionResponse? {
        try? JSONDecoder().decode(TransactionResponse.self, from: transactionData)
    }
}

struct TransactionBackup: Sendable, Codable, Identifiable {
    let id: Int
    let action: BackupAction
    let transaction: TransactionResponse
}
