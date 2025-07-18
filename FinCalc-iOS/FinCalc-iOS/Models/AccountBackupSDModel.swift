//
//  AccountBackupSDModel.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation
import SwiftData

@Model
final class AccountBackupSDModel {
    @Attribute(.unique) var id: Int
    var actionRaw: String
    var accountData: Data
    
    init(id: Int, action: BackupAction, account: Account) throws {
        self.id = id
        self.actionRaw = action.rawValue
        self.accountData = try JSONEncoder().encode(account)
    }
    
    var action: BackupAction? {
        BackupAction(rawValue: actionRaw)
    }
    
    var account: Account? {
        try? JSONDecoder().decode(Account.self, from: accountData)
    }
}

struct AccountBackup: Sendable, Codable, Identifiable {
    let id: Int
    let action: BackupAction
    let account: Account
}
