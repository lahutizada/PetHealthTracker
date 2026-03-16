//
//  GetHomeDataUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol GetHomeDataUseCaseProtocol {
    func execute() async throws -> (UserResponse, [PetResponse])
}

final class GetHomeDataUseCase: GetHomeDataUseCaseProtocol {
    
    private let authService: AuthServicing
    private let petsService: PetsServicing
    
    init(
        authService: AuthServicing = AuthService.shared,
        petsService: PetsServicing = PetsService.shared
    ) {
        self.authService = authService
        self.petsService = petsService
    }
    
    func execute() async throws -> (UserResponse, [PetResponse]) {
        async let user = authService.me()
        async let pets = petsService.getPets()
        return try await (user, pets)
    }
}
