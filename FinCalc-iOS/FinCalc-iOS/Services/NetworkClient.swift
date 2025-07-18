//
//  NetworkClient.swift
//  FinCalc-iOS
//
//  Created by Soslan Dzampaev on 17.07.2025.
//

import Foundation

struct EmptyResponse: Decodable {}

final class NetworkClient {
    // MARK: - Properties
    private let baseURL: URL
    private let session: URLSession
    private let token: String

    init(session: URLSession, token: String) {
        guard let url = URL(string: "https://shmr-finance.ru/api/v1/") else {
            preconditionFailure("Invalid base URL")
        }
        self.baseURL = url
        self.session = session
        self.token = token
    }
    
    func request<Request: Encodable, Response: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Request? = nil,
        responseType: Response.Type
    ) async throws -> Response {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw NetworkError.encodingFailed
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch {
            throw error
        }
    }
    
    func request<Response: Decodable>(
        endpoint: String,
        method: String = "GET",
        responseType: Response.Type
    ) async throws -> Response {
        guard let url = URL(string: endpoint, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...300).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            if Response.self == EmptyResponse.self && data.isEmpty {
                guard let empty = EmptyResponse() as? Response else {
                    fatalError("Type mismatch: Expected EmptyResponse for empty response")
                }
                return empty
            }
            
            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw NetworkError.decodingFailed(error)
            }
        } catch {
            throw error
        }
    }
}
