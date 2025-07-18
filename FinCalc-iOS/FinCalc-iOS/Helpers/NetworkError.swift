//
//  NetworkError.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.07.2025.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case encodingFailed
    case decodingFailed(Error)
    case httpError(Int)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неверный URL"
        case .encodingFailed:
            return "Не удалось закодировать данные"
        case .decodingFailed(let error):
            return "Ошибка при чтении ответа: \(error.localizedDescription)"
        case .httpError(let code):
            return "Ошибка сервера: код \(code)"
        case .invalidResponse:
            return "Некорректный ответ от сервера"
        }
    }
}
