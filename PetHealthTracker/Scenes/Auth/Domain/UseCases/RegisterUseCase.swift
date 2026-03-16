//
//  RegisterUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol RegisterUseCaseProtocol {
    func execute(name: String, email: String, password: String) async throws -> AuthResponse
}

final class RegisterUseCase: RegisterUseCaseProtocol {

    private let authService: AuthServicing

    init(authService: AuthServicing = AuthService.shared) {
        self.authService = authService
    }

    func execute(name: String, email: String, password: String) async throws -> AuthResponse {
        try await authService.register(name: name, email: email, password: password)
    }
}
