//
//  GetPetDetailsUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 17.03.26.
//

import Foundation

protocol GetPetDetailsUseCaseProtocol: AnyObject {
    func execute(id: String) async throws -> PetResponse
}

final class GetPetDetailsUseCase: GetPetDetailsUseCaseProtocol {
    
    private let petsService: PetsServicing
    
    init(petsService: PetsServicing = PetsService.shared) {
        self.petsService = petsService
    }
    
    func execute(id: String) async throws -> PetResponse {
        try await petsService.getPet(id: id)
    }
}
