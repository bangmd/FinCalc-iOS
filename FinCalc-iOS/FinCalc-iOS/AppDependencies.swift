//
//  AppDependencies.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.07.2025.
//

import Foundation

final class AppDependencies {
    let client = NetworkClient(session: .shared, token: "wWVUPYHncK4dcidYz6eUxOsg")
    lazy var transactionsService = TransactionsService(client: client)
    lazy var bankAccountsService = BankAccountsService(client: client)
    lazy var categoriesService = CategoriesService(client: client)
}
