//
//  SpoilerUIView.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 27.06.2025.
//

import SwiftUI
import UIKit

final class SpoilerUIView: UIView {
    // MARK: private sublayers
    private let emitter = CAEmitterLayer()

    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureEmitter()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: configuration
    private func configureEmitter() {
        emitter.frame = bounds
        emitter.emitterShape = .rectangle
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitter.emitterSize = bounds.size
        emitter.renderMode = .additive

        let cell = CAEmitterCell()
        cell.birthRate = 2
        cell.lifetime = 4
        cell.velocity = 12
        cell.velocityRange = 5
        cell.scale = 0.13
        cell.scaleRange = 0.006
        cell.alphaSpeed = -1.2
        cell.emissionRange = .pi * 2
        cell.contents = UIImage(named: "whiteDot")?.cgImage

        emitter.emitterCells = [cell]
        layer.addSublayer(emitter)
        emitter.birthRate = 0
    }

    // MARK: public API
    func hideWithAnimation() {
        emitter.beginTime = CACurrentMediaTime()
        emitter.birthRate = 120
    }

    func reveal() {
        emitter.birthRate = 0
    }

    // MARK: layout
    override func layoutSubviews() {
        super.layoutSubviews()
        emitter.frame = bounds
        emitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        emitter.emitterSize = bounds.size
    }
}

struct SpoilerOverlay: UIViewRepresentable {
    @Binding var hidden: Bool

    func makeUIView(context: Context) -> SpoilerUIView {
        let view = SpoilerUIView()
        if hidden {
            view.hideWithAnimation()
        } else {
            view.reveal()
        }
        return view
    }

    func updateUIView(_ uiView: SpoilerUIView, context: Context) {
        if hidden {
            uiView.hideWithAnimation()
        } else {
            uiView.reveal()
        }
    }
}
