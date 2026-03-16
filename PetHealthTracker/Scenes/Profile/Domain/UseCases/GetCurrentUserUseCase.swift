//
//  GetCurrentUserUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol GetCurrentUserUseCaseProtocol {
    func execute() async throws -> UserResponse
}

final class GetCurrentUserUseCase: GetCurrentUserUseCaseProtocol {

    private let authService: AuthServicing

    init(authService: AuthServicing = AuthService.shared) {
        self.authService = authService
    }

    func execute() async throws -> UserResponse {
        try await authService.me()
    }
}
