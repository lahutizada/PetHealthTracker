//
//  SessionManager.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import Foundation

final class SessionManager {
    static let shared = SessionManager()
    
    private init() {}
    
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"
    
    var accessToken: String? {
        KeychainManager.shared.get(key: accessTokenKey)
    }
    
    var refreshToken: String? {
        KeychainManager.shared.get(key: refreshTokenKey)
    }
    
    var isLoggedIn: Bool {
        accessToken != nil && refreshToken != nil
    }
    
    func saveTokens(accessToken: String, refreshToken: String) {
        KeychainManager.shared.save(key: accessTokenKey, value: accessToken)
        KeychainManager.shared.save(key: refreshTokenKey, value: refreshToken)
    }
    
    func clearSession() {
        KeychainManager.shared.delete(key: accessTokenKey)
        KeychainManager.shared.delete(key: refreshTokenKey)
    }
}
