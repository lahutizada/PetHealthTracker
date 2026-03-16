//
//  LogoutUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol LogoutUseCaseProtocol {
    func execute() async throws
}

final class LogoutUseCase: LogoutUseCaseProtocol {

    private let authService: AuthServicing

    init(authService: AuthServicing = AuthService.shared) {
        self.authService = authService
    }

    func execute() async throws {
        try await authService.logout()
        SessionManager.shared.clearSession()
    }
}
