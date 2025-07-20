//
//  File.swift
//  FinCalcCore
//
//  Created by Soslan Dzampaev on 21.07.2025.
//

import SwiftUI
import Lottie

public struct LottieView: UIViewRepresentable {
    public let animationName: String
    public let loopMode: LottieLoopMode
    public let onFinished: (() -> Void)?
    
    public init(animationName: String, loopMode: LottieLoopMode = .playOnce, onFinished: (() -> Void)? = nil) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.onFinished = onFinished
    }
    
    public func makeUIView(context: Context) -> UIView {
        let container = UIView()
        let animationView = LottieAnimationView(name: animationName)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: container.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        animationView.play { finished in
            if finished {
                onFinished?()
            }
        }
        return container
    }
    
    public func updateUIView(_ uiView: UIView, context: Context) {}
}
