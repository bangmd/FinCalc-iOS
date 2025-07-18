//
//  NetworkMonitor.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 19.07.2025.
//
import Foundation
import Network

final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    @Published var isConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                print("Состояние сети: \(self?.isConnected == true ? "Онлайн" : "Оффлайн")")

            }
        }
        monitor.start(queue: queue)
    }
}
