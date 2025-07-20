//
//  FinCalc_iOSApp.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import SwiftUI
import FinCalcCore

@main
struct FinCalc: App {
    let networkClient = NetworkClient(session: .shared, token: "wWVUPYHncK4dcidYz6eUxOsg")
    let transactionsService: TransactionsService
    let bankAccountsService: BankAccountsService
    
    @State private var showLottie = true
    
    init() {
        self.transactionsService = TransactionsService(
            client: networkClient,
            persistence: AppDependencies.transactionsPersistence,
            backup: AppDependencies.transactionsBackup,
            categoriesPersistence: AppDependencies.categoriesPersistence,
            accountsPersistence: AppDependencies.accountsPersistence,
            accountsBackup: AppDependencies.accountsBackup
        )
        self.bankAccountsService = BankAccountsService(
            client: networkClient,
            persistence: AppDependencies.accountsPersistence,
            backup: AppDependencies.accountsBackup
        )
        configureTabBarAppearance()
        
        Task { @MainActor in
            let textField = UITextField(frame: .zero)
            if let window = UIApplication.shared
                .connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first?
                .windows
                .first {
                window.addSubview(textField)
                textField.becomeFirstResponder()
                textField.resignFirstResponder()
                textField.removeFromSuperview()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if showLottie {
                    LottieView(animationName: "Lottie-JSON", onFinished: {
                        withAnimation {
                            showLottie = false
                        }
                    })
                    .ignoresSafeArea()
                } else {
                    TabBarView()
                        .environmentObject(NetworkMonitor.shared)
                        .task {
                            await AccountViewModel.preloadAccountInfo(service: bankAccountsService)
                        }
                }
            }
        }
    }
}

private extension FinCalc {
    func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
