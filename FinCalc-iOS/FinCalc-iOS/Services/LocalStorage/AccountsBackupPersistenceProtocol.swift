//
//  AccountsBackupPersistenceProtocol.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation

protocol AccountsBackupPersistenceProtocol: Sendable {
    func allBackups() async throws -> [AccountBackup]
    func addOrUpdateBackup(_ backup: AccountBackup) async throws
    func deleteBackup(id: Int) async throws
}
