//
//  ResetPasswordUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol ResetPasswordUseCaseProtocol {
    func execute(token: String, newPassword: String) async throws
}

final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {

    private let authService: AuthServicing

    init(authService: AuthServicing = AuthService.shared) {
        self.authService = authService
    }

    func execute(token: String, newPassword: String) async throws {
        try await authService.resetPassword(token: token, newPassword: newPassword)
    }
}
