//
//  AddPetViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 16.03.26.
//

import UIKit

protocol AddPetViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onPetCreated: ((PetResponse) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    
    func savePet(
        mode: PetFormMode,
        species: String?,
        name: String?,
        sex: String?,
        neutered: Bool,
        breed: String?,
        dob: String?,
        weight: Double?,
        image: UIImage?
    )
    
    func clearError()
}

final class AddPetViewModel: AddPetViewModelProtocol {
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onPetCreated: ((PetResponse) -> Void)?
    var onError: ((String?) -> Void)?
    
    private let createPetUseCase: CreatePetUseCaseProtocol
    private let uploadPetPhotoUseCase: UploadPetPhotoUseCaseProtocol
    
    init(
        createPetUseCase: CreatePetUseCaseProtocol = CreatePetUseCase(),
        uploadPetPhotoUseCase: UploadPetPhotoUseCaseProtocol = UploadPetPhotoUseCase()
    ) {
        self.createPetUseCase = createPetUseCase
        self.uploadPetPhotoUseCase = uploadPetPhotoUseCase
    }
    
    func savePet(
        mode: PetFormMode,
        species: String?,
        name: String?,
        sex: String?,
        neutered: Bool,
        breed: String?,
        dob: String?,
        weight: Double?,
        image: UIImage?
    ) {
        clearError()
        
        let cleanSpecies = species?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanSex = sex?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanBreed = breed?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDob = dob?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanSpecies.isEmpty else {
            onError?("Species is required")
            return
        }
        
        guard !cleanName.isEmpty else {
            onError?("Pet name is required")
            return
        }
        
        guard !cleanSex.isEmpty else {
            onError?("Sex is required")
            return
        }
        
        if let weight, weight <= 0 {
            onError?("Weight must be greater than 0")
            return
        }
        
        let request = CreatePetRequest(
            species: cleanSpecies,
            name: cleanName,
            sex: cleanSex,
            neutered: neutered,
            breed: cleanBreed?.isEmpty == true ? nil : cleanBreed,
            dob: cleanDob?.isEmpty == true ? nil : cleanDob,
            weight: weight
        )
        
        onLoadingStateChanged?(true)
        
        Task {
            do {
                let savedPet: PetResponse
                
                switch mode {
                case .create:
                    savedPet = try await createPetUseCase.execute(requestModel: request)
                case .edit(let pet):
                    savedPet = try await createPetUseCase.update(id: pet.id, requestModel: request)
                }
                
                let finalPet: PetResponse
                
                if let image {
                    finalPet = try await uploadPetPhotoUseCase.execute(
                        petId: savedPet.id,
                        image: image
                    )
                } else {
                    finalPet = savedPet
                }
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onPetCreated?(finalPet)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to save pet")
                }
            }
        }
    }
    
    func clearError() {
        onError?(nil)
    }
}
