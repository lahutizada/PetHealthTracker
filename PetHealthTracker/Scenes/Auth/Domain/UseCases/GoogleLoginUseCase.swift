//
//  GoogleLoginUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 28.03.26.
//

import Foundation

protocol GoogleLoginUseCaseProtocol {
    func execute(idToken: String) async throws -> AuthResponse
}

final class GoogleLoginUseCase: GoogleLoginUseCaseProtocol {
    
    private let authService: AuthServicing
    
    init(authService: AuthServicing = AuthService.shared) {
        self.authService = authService
    }
    
    func execute(idToken: String) async throws -> AuthResponse {
        try await authService.googleAuth(idToken: idToken)
    }
}
