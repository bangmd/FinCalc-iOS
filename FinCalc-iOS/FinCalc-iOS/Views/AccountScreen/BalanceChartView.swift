//
//  BalanceChartView.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 20.07.2025.
//

import SwiftUI
import Charts

enum ChartPeriod: String, CaseIterable, Identifiable {
    case daily = "По дням"
    case monthly = "По месяцам"
    var id: String { rawValue }
}

struct BalanceChartView: View {
    let balances: [DailyBalance]
    let monthlyBalances: [DailyBalance]  
    @State private var chartPeriod: ChartPeriod = .daily
    @State private var selectedBalance: DailyBalance? = nil
    @State private var isDragging: Bool = false
    
    var currentBalances: [DailyBalance] {
        chartPeriod == .daily ? balances : monthlyBalances
    }
    
    var body: some View {
        let labelDates: [Date] = [
            currentBalances.first?.date,
            currentBalances.count > 1 ? currentBalances[currentBalances.count / 2].date : nil,
            currentBalances.last?.date
        ].compactMap { $0 }
        
        VStack(alignment: .leading) {
            Picker("", selection: $chartPeriod) {
                ForEach(ChartPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .animation(.easeInOut, value: chartPeriod)
            
            ZStack {
                Chart {
                    ForEach(currentBalances) { point in
                        BarMark(
                            x: .value("Дата", point.date),
                            y: .value("Баланс", max(abs(point.balance.doubleValue), 2)) // min высота для "нуля"
                        )
                        .foregroundStyle(
                            point.balance.doubleValue == 0
                            ? Color.black.opacity(0.3)
                            : (point.balance > 0 ? Color.accentColor : Color.orangeForGraph)
                        )
                        .cornerRadius(6)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: labelDates) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(chartPeriod == .daily
                                     ? Self.dateFormatter.string(from: date)
                                     : Self.monthFormatter.string(from: date))
                                .font(.caption)
                            }
                        }
                    }
                }
                .chartYAxis { }
                .frame(height: 220)
                .padding(.horizontal, 8)
                .chartOverlay { proxy in
                    ChartOverlayView(
                        balances: currentBalances,
                        isDragging: $isDragging,
                        selectedBalance: $selectedBalance,
                        proxy: proxy
                    )
                }
                .transition(.opacity)
                .animation(.easeInOut, value: chartPeriod)
                
                if let selected = selectedBalance, isDragging {
                    TooltipView(balance: selected, chartPeriod: chartPeriod)
                        .position(x: tooltipX(selected: selected, in: currentBalances), y: 40)
                        .animation(.easeInOut, value: selected.id)
                }
            }
        }
    }
    
    private func tooltipX(selected: DailyBalance, in balances: [DailyBalance]) -> CGFloat {
        guard let first = balances.first, let last = balances.last, first.date != last.date else { return 0 }
        let minX: CGFloat = 40
        let maxX: CGFloat = 340 - 40
        let progress = CGFloat(
            (selected.date.timeIntervalSince1970 - first.date.timeIntervalSince1970) /
            (last.date.timeIntervalSince1970 - first.date.timeIntervalSince1970)
        )
        return minX + (maxX - minX) * progress
    }
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM"
        return formatter
    }()
    static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.setLocalizedDateFormatFromTemplate("LLLL yyyy")
        return formatter
    }()
}

// Overlay — ловим жесты для тултипа
private struct ChartOverlayView: View {
    let balances: [DailyBalance]
    @Binding var isDragging: Bool
    @Binding var selectedBalance: DailyBalance?
    let proxy: ChartProxy
    
    var body: some View {
        GeometryReader { geo in
            Rectangle()
                .fill(Color.clear)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isDragging = true
                            guard let plotFrame = proxy.plotFrame else { return }
                            let chartOrigin = geo[plotFrame].origin.x
                            let xInChart = value.location.x - chartOrigin
                            if let date: Date = proxy.value(atX: xInChart) {
                                if let nearest = nearestBalance(for: date) {
                                    selectedBalance = nearest
                                }
                            }
                        }
                        .onEnded { _ in
                            isDragging = false
                            selectedBalance = nil
                        }
                )
        }
    }
    
    private func nearestBalance(for date: Date) -> DailyBalance? {
        let touchTime = date.timeIntervalSince1970
        return balances.min(by: {
            abs($0.date.timeIntervalSince1970 - touchTime) < abs($1.date.timeIntervalSince1970 - touchTime)
        })
    }
}

// Tooltip
private struct TooltipView: View {
    let balance: DailyBalance
    let chartPeriod: ChartPeriod
    
    var body: some View {
        VStack(spacing: 2) {
            Text(balance.balance.formattedPlain)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Text(chartPeriod == .daily
                 ? BalanceChartView.dateFormatter.string(from: balance.date)
                 : BalanceChartView.monthFormatter.string(from: balance.date))
            .font(.caption2)
            .foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 16)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.92))
        )
        .shadow(radius: 6, y: 2)
    }
}

private extension Decimal {
    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
    var formattedPlain: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: self)) ?? ""
    }
}
