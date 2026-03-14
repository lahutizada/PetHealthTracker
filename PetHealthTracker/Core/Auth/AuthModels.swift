//
//  AuthModels.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 08.03.26.
//

import Foundation

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let fullName: String
    let email: String
    let password: String
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ResetPasswordRequest: Codable {
    let token: String
    let newPassword: String
}

struct EmptyResponse: Codable {}

struct AppleAuthRequest: Codable {
    let identityToken: String
    let authorizationCode: String?
    let fullName: String?
    let email: String?
}

struct GoogleAuthRequest: Codable {
    let idToken: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}
