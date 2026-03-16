//
//  GetPetsUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol GetPetsUseCaseProtocol {
    func execute() async throws -> [PetResponse]
}

final class GetPetsUseCase: GetPetsUseCaseProtocol {

    private let petsService: PetsServicing

    init(petsService: PetsServicing = PetsService.shared) {
        self.petsService = petsService
    }

    func execute() async throws -> [PetResponse] {
        try await petsService.getPets()
    }
}
