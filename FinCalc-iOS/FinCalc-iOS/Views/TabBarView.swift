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

    @ViewBuilder
    var screen: some View {
        switch self {
        case .outcomes: TransactionsListView(direction: .outcome)
        case .incomes: TransactionsListView(direction: .income)
        case .account: AccountScreen()
        case .articles: ExpensesScreen()
        case .settings: SettingsScreen()
        }
    }
}

// MARK: - TabBarView
struct TabBarView: View {
    var body: some View {
        TabView {
            ForEach(TabBarItem.allCases) { item in
                item.screen
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
    }
}

#Preview {
    TabBarView()
}
