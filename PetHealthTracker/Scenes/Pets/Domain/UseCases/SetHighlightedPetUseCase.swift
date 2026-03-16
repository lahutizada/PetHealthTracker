//
//  SetHighlightedPetUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol SetHighlightedPetUseCaseProtocol {
    func execute(id: String) async throws -> PetResponse
}

final class SetHighlightedPetUseCase: SetHighlightedPetUseCaseProtocol {

    private let petsService: PetsServicing

    init(petsService: PetsServicing = PetsService.shared) {
        self.petsService = petsService
    }

    func execute(id: String) async throws -> PetResponse {
        try await petsService.setHighlightedPet(id: id)
    }
}
