//
//  DeletePetPhotoUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

protocol DeletePetPhotoUseCaseProtocol {
    func execute(id: String) async throws -> PetResponse
}

final class DeletePetPhotoUseCase: DeletePetPhotoUseCaseProtocol {
    
    private let petsService: PetsServicing
    
    init(petsService: PetsServicing = PetsService.shared) {
        self.petsService = petsService
    }
    
    func execute(id: String) async throws -> PetResponse {
        try await petsService.deletePetPhoto(id: id)
    }
}
