//
//  UploadPetPhotoUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 16.03.26.
//

import UIKit

protocol UploadPetPhotoUseCaseProtocol {
    func execute(petId: String, image: UIImage) async throws -> PetResponse
}

final class UploadPetPhotoUseCase: UploadPetPhotoUseCaseProtocol {
    
    private let petsService: PetsServicing
    
    init(petsService: PetsServicing = PetsService.shared) {
        self.petsService = petsService
    }
    
    func execute(petId: String, image: UIImage) async throws -> PetResponse {
        try await petsService.uploadPetPhoto(petId: petId, image: image)
    }
}
