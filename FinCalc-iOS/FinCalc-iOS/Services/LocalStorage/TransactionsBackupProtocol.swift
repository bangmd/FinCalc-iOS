//
//  TransactionsBackupProtocol.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation

enum BackupAction: String, Codable {
    case create, update, delete
}

protocol TransactionsBackupPersistenceProtocol: Sendable {
    func allBackups() async throws -> [TransactionBackup]
    func addOrUpdateBackup(_ backup: TransactionBackup) async throws
    func deleteBackup(id: Int) async throws
}
