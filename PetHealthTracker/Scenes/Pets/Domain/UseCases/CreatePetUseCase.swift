//
//  CreatePetUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol CreatePetUseCaseProtocol {
    func execute(requestModel: CreatePetRequest) async throws -> PetResponse
    func update(id: String, requestModel: CreatePetRequest) async throws -> PetResponse
}

final class CreatePetUseCase: CreatePetUseCaseProtocol {
    
    private let petsService: PetsServicing
    
    init(petsService: PetsServicing = PetsService.shared) {
        self.petsService = petsService
    }
    
    func execute(requestModel: CreatePetRequest) async throws -> PetResponse {
        try await petsService.createPet(requestModel)
    }
    
    func update(id: String, requestModel: CreatePetRequest) async throws -> PetResponse {
        try await petsService.updatePet(id: id, requestModel: requestModel)
    }
}
