//
//  FinCalc_iOSApp.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 08.06.2025.
//

import SwiftUI

@main
struct FinCalc: App {
    init() {
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
                TabBarView()
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
