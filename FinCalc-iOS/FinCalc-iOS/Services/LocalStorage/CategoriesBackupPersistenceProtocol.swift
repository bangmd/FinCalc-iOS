//
//  CategoriesBackupPersistenceProtocol.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 18.07.2025.
//

import Foundation

protocol CategoriesBackupPersistenceProtocol: Sendable {
    func allBackups() async throws -> [CategoryBackup]
    func addOrUpdateBackup(_ backup: CategoryBackup) async throws
    func deleteBackup(id: Int) async throws
}
