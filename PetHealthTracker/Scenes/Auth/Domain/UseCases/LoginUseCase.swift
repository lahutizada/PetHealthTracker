//
//  LoginUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> AuthResponse
}

final class LoginUseCase: LoginUseCaseProtocol {

    private let authService: AuthServicing

    init(authService: AuthServicing = AuthService.shared) {
        self.authService = authService
    }

    func execute(email: String, password: String) async throws -> AuthResponse {
        try await authService.login(email: email, password: password)
    }
}
