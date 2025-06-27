//
//  TabBarView.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.06.2025.
//

import SwiftUI

// MARK: - TabBarItem
enum TabBarItem: String, Identifiable, CaseIterable {
    case outcomes, incomes, account, articles, settings

    var id: String { rawValue }

    var icon: Image {
        switch self {
        case .outcomes: Image("downtrend")
        case .incomes:  Image("uptrend")
        case .account:  Image("calculator")
        case .articles: Image("icons")
        case .settings: Image("vector")
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .outcomes: "tab_outcomes"
        case .incomes:  "tab_incomes"
        case .account:  "tab_account"
        case .articles: "tab_articles"
        case .settings: "tab_settings"
        }
    }
}

// MARK: - TabBarView
struct TabBarView: View {
    @State private var isBalanceHidden = false
    @StateObject private var accountVM = AccountViewModel()

    var body: some View {
        TabView {
            ForEach(TabBarItem.allCases) { item in
                screen(for: item)
                    .tabItem {
                        item.icon
                            .renderingMode(.template)
                            .frame(width: 21, height: 21)
                            .aspectRatio(contentMode: .fit)
                        Text(item.title)
                    }
            }
        }
        .tint(Color.accentColor)
        .background(Color(.systemGray6))
        .ignoresSafeArea(.container, edges: .top)
    }

    // MARK: - Helper
    @ViewBuilder
    private func screen(for item: TabBarItem) -> some View {
        switch item {
        case .outcomes:
            TransactionsListView(direction: .outcome)
        case .incomes:
            TransactionsListView(direction: .income)
        case .account:
            ZStack {
                AccountScreen(viewModel: accountVM, isBalanceHidden: $isBalanceHidden)
                if !accountVM.isEditing {
                    ShakableViewRepresentable {
                        withAnimation { isBalanceHidden.toggle() }
                    }
                    .allowsHitTesting(false)
                }
            }
        case .articles:
            ExpensesScreen()
        case .settings:
            SettingsScreen()
        }
    }
}

// MARK: - Preview
#Preview {
    TabBarView()
}
