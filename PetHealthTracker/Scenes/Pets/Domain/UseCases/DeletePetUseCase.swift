//
//  DeletePetUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 16.03.26.
//

protocol DeletePetUseCaseProtocol {
    func execute(id: String) async throws
}

final class DeletePetUseCase: DeletePetUseCaseProtocol {
    private let petsService: PetsServicing
    
    init(petsService: PetsServicing = PetsService.shared) {
        self.petsService = petsService
    }
    
    func execute(id: String) async throws {
        try await petsService.deletePet(id: id)
    }
}
