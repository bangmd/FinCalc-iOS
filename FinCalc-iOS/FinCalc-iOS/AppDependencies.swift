//
//  AppDependencies.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.07.2025.
//

import Foundation
import SwiftData

final class AppDependencies {
    let client = NetworkClient(session: .shared, token: "wWVUPYHncK4dcidYz6eUxOsg")
    
    static let modelContainer: ModelContainer = {
        do {
            return try ModelContainer(
                for:
                    TransactionSDModel.self,
                TransactionBackupSDModel.self,
                AccountSDModel.self,
                AccountBackupSDModel.self,
                CategorySDModel.self,
                CategoryBackupSDModel.self
            )
        } catch {
            fatalError("Не удалось инициализировать SwiftData контейнер: \(error)")
        }
    }()
    
    static let transactionsPersistence = TransactionsSwiftDataStore(container: modelContainer)
    static let transactionsBackup = TransactionsBackupSwiftDataStore(container: modelContainer)
    
    static let accountsPersistence = BankAccountsSwiftDataStore(container: modelContainer)
    static let accountsBackup = AccountsBackupSwiftDataStore(container: modelContainer)
    
    static let categoriesPersistence = CategoriesSwiftDataStore(container: modelContainer)
    static let categoriesBackup = CategoriesBackupSwiftDataStore(container: modelContainer)
    
    lazy var transactionsService = TransactionsService(
        client: client,
        persistence: AppDependencies.transactionsPersistence,
        backup: AppDependencies.transactionsBackup,
        categoriesPersistence: AppDependencies.categoriesPersistence,
        accountsPersistence: AppDependencies.accountsPersistence,
        accountsBackup: AppDependencies.accountsBackup
    )
    lazy var bankAccountsService = BankAccountsService(
        client: client,
        persistence: AppDependencies.accountsPersistence,
        backup: AppDependencies.accountsBackup
    )
    lazy var categoriesService = CategoriesService(
        client: client,
        persistence: AppDependencies.categoriesPersistence,
        backup: AppDependencies.categoriesBackup
    )
}
