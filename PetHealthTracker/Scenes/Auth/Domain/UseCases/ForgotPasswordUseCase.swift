//
//  ForgotPasswordUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol ForgotPasswordUseCaseProtocol {
    func execute(email: String) async throws
}

final class ForgotPasswordUseCase: ForgotPasswordUseCaseProtocol {

    private let authService: AuthServicing

    init(authService: AuthServicing = AuthService.shared) {
        self.authService = authService
    }

    func execute(email: String) async throws {
        try await authService.forgotPassword(email: email)
    }
}
