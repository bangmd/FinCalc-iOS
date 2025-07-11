//
//  AnalysisViewControllerWrapper.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 10.07.2025.
//

import SwiftUI

// MARK: - UIKit Wrapper for AnalysisViewController
struct AnalysisViewControllerWrapper: UIViewControllerRepresentable {
    let direction: Direction
    let fromDate: Date
    let toDate: Date
    
    func makeUIViewController(context: Context) -> AnalysisViewController {
        AnalysisViewController(direction: direction, fromDate: fromDate, toDate: toDate)
    }
    
    func updateUIViewController(_ uiViewController: AnalysisViewController, context: Context) {}
}
