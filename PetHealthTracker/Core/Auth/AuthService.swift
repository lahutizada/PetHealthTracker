//
//  AuthService.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 08.03.26.
//

import Foundation

final class AuthService: AuthServicing {

    static let shared = AuthService()

    func login(email: String, password: String) async throws -> AuthResponse {
        let body = try JSONEncoder().encode(
            LoginRequest(email: email, password: password)
        )

        return try await APIClient.shared.request(
            endpoint: "/auth/login",
            method: "POST",
            body: body
        )
    }

    func register(name: String, email: String, password: String) async throws -> AuthResponse {
        let body = try JSONEncoder().encode(
            RegisterRequest(fullName: name, email: email, password: password)
        )

        return try await APIClient.shared.request(
            endpoint: "/auth/register",
            method: "POST",
            body: body
        )
    }

    func me() async throws -> UserResponse {
        try await APIClient.shared.request(
            endpoint: "/auth/me",
            method: "GET",
            requiresAuth: true
        )
    }

    func forgotPassword(email: String) async throws {
        let body = try JSONEncoder().encode(
            ForgotPasswordRequest(email: email)
        )

        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/auth/forgot-password",
            method: "POST",
            body: body
        )
    }

    func resetPassword(token: String, newPassword: String) async throws {
        let body = try JSONEncoder().encode(
            ResetPasswordRequest(token: token, newPassword: newPassword)
        )

        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/auth/reset-password",
            method: "POST",
            body: body
        )
    }

    func logout() async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "/auth/logout",
            method: "POST",
            requiresAuth: true
        )
    }
}
