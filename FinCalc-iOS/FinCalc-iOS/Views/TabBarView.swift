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

    var iconName: String {
        switch self {
        case .outcomes: "downtrend"
        case .incomes: "uptrend"
        case .account: "calculator"
        case .articles: "icons"
        case .settings: "vector"
        }
    }

    var title: String {
        switch self {
        case .outcomes: "Расходы"
        case .incomes: "Доходы"
        case .account: "Счет"
        case .articles: "Статьи"
        case .settings: "Настройки"
        }
    }

    @ViewBuilder
    var screen: some View {
        switch self {
        case .outcomes: OutcomesScreen()
        case .incomes: IncomesScreen()
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
                        Image(item.iconName)
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
