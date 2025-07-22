//
//  PieChartView.swift
//  Utilities
//
//  Created by Soslan Dzampaev on 20.07.2025.
//
import UIKit

public class PieChartView: UIView {
    public private(set) var entities: [Entity] = []
    public static let colors: [UIColor] = [
        UIColor.systemGreen,
        UIColor.systemYellow,
        UIColor.systemBlue,
        UIColor.systemRed,
        UIColor.systemPurple,
        UIColor.systemGray
    ]
    
    private var isAnimating = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    public convenience init(frame: CGRect, entities: [Entity]) {
        self.init(frame: frame)
        self.entities = entities
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }
    
    public func setEntities(_ newEntities: [Entity], animated: Bool = true) {
        if !animated {
            self.entities = newEntities
            self.setNeedsDisplay()
            return
        }
        guard !isAnimating else { return }
        isAnimating = true
        UIView.animate(withDuration: 0.38, animations: {
            self.transform = CGAffineTransform(rotationAngle: .pi)
            self.alpha = 0
        }) { _ in
            self.entities = newEntities
            self.setNeedsDisplay()
            self.transform = CGAffineTransform(rotationAngle: .pi)
            self.alpha = 0
            UIView.animate(withDuration: 0.38, animations: {
                self.transform = CGAffineTransform(rotationAngle: 2 * .pi)
                self.alpha = 1
            }) { _ in
                self.transform = .identity
                self.isAnimating = false
            }
        }
    }
    
    public override func draw(_ rect: CGRect) {
        if entities.isEmpty || entities.reduce(Decimal(0), { $0 + $1.value }) == 0 {
            drawPlaceholder(rect: rect)
            return
        }
        
        var pieEntities = Array(entities.prefix(5))
        if entities.count > 5 {
            let restValue = entities.dropFirst(5).reduce(Decimal(0)) { $0 + $1.value }
            let rest = Entity(value: restValue, label: "Остальные")
            pieEntities.append(rest)
        }
        let total = pieEntities.reduce(Decimal(0)) { $0 + $1.value }
        guard total > 0 else {
            drawPlaceholder(rect: rect)
            return
        }
        let radius = (min(rect.width, rect.height) - 8) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var startAngle = -CGFloat.pi / 2
        for (index, entity) in pieEntities.enumerated() {
            let valueNum = NSDecimalNumber(decimal: entity.value)
            let totalNum = NSDecimalNumber(decimal: total)
            let fraction = totalNum == 0 ? 0 : valueNum.dividing(by: totalNum).doubleValue
            let endAngle = startAngle + CGFloat(fraction) * 2 * .pi
            let path = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            path.lineWidth = 8
            PieChartView.colors[index % PieChartView.colors.count].setStroke()
            path.stroke()
            startAngle = endAngle
        }
        drawLegend(entities: pieEntities, rect: rect, total: total)
    }
    
    private func drawLegend(entities: [Entity], rect: CGRect, total: Decimal) {
        let legendFont = UIFont.systemFont(ofSize: 7, weight: .regular)
        let dotSize: CGFloat = 5
        let spacing: CGFloat = 2
        let verticalSpacing: CGFloat = 3
        
        var maxTextWidth: CGFloat = 0
        let percentFormatter = NumberFormatter()
        percentFormatter.maximumFractionDigits = 0
        
        for entity in entities {
            let valueNum = NSDecimalNumber(decimal: entity.value)
            let totalNum = NSDecimalNumber(decimal: total)
            let percent = totalNum == 0 ? 0 : valueNum.dividing(by: totalNum).doubleValue * 100
            let text = String(format: "%.0f%% %@", percent, entity.label)
            let attrText = NSAttributedString(string: text, attributes: [.font: legendFont])
            let size = attrText.size()
            if size.width > maxTextWidth {
                maxTextWidth = size.width
            }
        }
        let legendWidth = maxTextWidth + dotSize + spacing + 8
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let legendHeight = CGFloat(entities.count) * dotSize + CGFloat(entities.count - 1) * verticalSpacing
        let legendTop = center.y - legendHeight / 2
        let legendLeft = center.x - legendWidth / 2
        
        for (index, entity) in entities.enumerated() {
            let valueNum = NSDecimalNumber(decimal: entity.value)
            let totalNum = NSDecimalNumber(decimal: total)
            let percent = totalNum == 0 ? 0 : valueNum.dividing(by: totalNum).doubleValue * 100
            
            let dotRect = CGRect(
                x: legendLeft,
                y: legendTop + CGFloat(index) * (dotSize + verticalSpacing),
                width: dotSize,
                height: dotSize
            )
            let dotPath = UIBezierPath(ovalIn: dotRect)
            PieChartView.colors[index % PieChartView.colors.count].setFill()
            dotPath.fill()
            
            let text = String(format: "%.0f%% %@", percent, entity.label)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: legendFont,
                .foregroundColor: UIColor.black
            ]
            let textRect = CGRect(
                x: legendLeft + dotSize + spacing,
                y: legendTop + CGFloat(index) * (dotSize + verticalSpacing) - 1,
                width: maxTextWidth + 6,
                height: dotSize + 6
            )
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func drawPlaceholder(rect: CGRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: UIColor.systemGray,
            .paragraphStyle: paragraphStyle
        ]
        let text = "Нет данных"
        let size = text.size(withAttributes: attrs)
        let textRect = CGRect(
            x: rect.midX - size.width / 2,
            y: rect.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
        text.draw(in: textRect, withAttributes: attrs)
    }
}
