//
//  APIClient.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 08.03.26.
//

import Foundation

final class APIClient {
    
    static let shared = APIClient()
    
    private let baseURL = "http://192.168.1.68:3000"
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        requiresAuth: Bool = false,
        retryOnUnauthorized: Bool = true
    ) async throws -> T {
        
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.httpBody = body
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth, let accessToken = SessionManager.shared.accessToken {
            urlRequest.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        print("URL:", url.absoluteString)
        print("Method:", method)
        
        if let body = body,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body:", bodyString)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        print("Status Code:", http.statusCode)
        
        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Body:", responseString)
        }
        
        if http.statusCode == 401 && requiresAuth && retryOnUnauthorized {
            let refreshed = try await refreshAccessToken()
            
            if refreshed {
                return try await self.request(
                    endpoint: endpoint,
                    method: method,
                    body: body,
                    requiresAuth: requiresAuth,
                    retryOnUnauthorized: false
                )
            } else {
                SessionManager.shared.clearSession()
                throw NSError(
                    domain: "APIClientError",
                    code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "Session expired. Please log in again."]
                )
            }
        }
        
        guard 200...299 ~= http.statusCode else {
            let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
            print("Request failed with status:", http.statusCode)
            print("Error body:", errorBody)
            
            throw NSError(
                domain: "APIClientError",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: errorBody]
            )
        }
        
        if T.self == EmptyResponse.self {
            return EmptyResponse() as! T
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    private func refreshAccessToken() async throws -> Bool {
        guard let refreshToken = SessionManager.shared.refreshToken else {
            return false
        }
        
        let body = try JSONEncoder().encode(
            RefreshTokenRequest(refreshToken: refreshToken)
        )
        
        guard let url = URL(string: baseURL + "/auth/refresh") else {
            return false
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = body
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let http = response as? HTTPURLResponse,
              200...299 ~= http.statusCode else {
            return false
        }
        
        let tokens = try JSONDecoder().decode(AuthResponse.self, from: data)
        SessionManager.shared.saveTokens(
            accessToken: tokens.accessToken,
            refreshToken: tokens.refreshToken
        )
        return true
    }
}
