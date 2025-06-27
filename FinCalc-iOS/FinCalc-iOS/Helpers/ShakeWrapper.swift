//
//  ShakeWrapper.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 27.06.2025.
//

import SwiftUI
import UIKit

struct ShakableViewRepresentable: UIViewControllerRepresentable {
    let onShake: () -> Void

    class Controller: UIViewController {
        var onShake: (() -> Void)?

        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            super.motionEnded(motion, with: event)
            if motion == .motionShake {
                onShake?()
            }
        }

        override var canBecomeFirstResponder: Bool {
            true
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            becomeFirstResponder()
        }
    }

    func makeUIViewController(context: Context) -> Controller {
        let ctrl = Controller()
        ctrl.onShake = onShake
        ctrl.view.backgroundColor = .clear
        ctrl.view.isUserInteractionEnabled = false
        return ctrl
    }

    func updateUIViewController(_ uiViewController: Controller, context: Context) {
        uiViewController.onShake = onShake
    }
}
