//
//  PetsViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol PetsViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onPetsLoaded: (([PetResponse]) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    func loadPets()
    func refreshPets()
    func setMainPet(_ pet: PetResponse)
}

final class PetsViewModel: PetsViewModelProtocol {

    var onLoadingStateChanged: ((Bool) -> Void)?
    var onPetsLoaded: (([PetResponse]) -> Void)?
    var onError: ((String) -> Void)?

    private let getPetsUseCase: GetPetsUseCaseProtocol
    private let setHighlightedPetUseCase: SetHighlightedPetUseCaseProtocol

    private var pets: [PetResponse] = []

    init(
        getPetsUseCase: GetPetsUseCaseProtocol = GetPetsUseCase(),
        setHighlightedPetUseCase: SetHighlightedPetUseCaseProtocol = SetHighlightedPetUseCase()
    ) {
        self.getPetsUseCase = getPetsUseCase
        self.setHighlightedPetUseCase = setHighlightedPetUseCase
    }

    func loadPets() {
        onLoadingStateChanged?(true)

        Task {
            do {
                let response = try await getPetsUseCase.execute()
                let sortedPets = sortPets(response)
                self.pets = sortedPets

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onPetsLoaded?(sortedPets)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to load pets")
                }
            }
        }
    }

    func refreshPets() {
        loadPets()
    }

    func setMainPet(_ pet: PetResponse) {
        guard pet.isHighlighted != true else { return }

        Task {
            do {
                let updatedPet = try await setHighlightedPetUseCase.execute(id: pet.id)

                let updatedPets = pets.map { currentPet in
                    PetResponse(
                        id: currentPet.id,
                        userId: currentPet.userId,
                        species: currentPet.species,
                        name: currentPet.name,
                        sex: currentPet.sex,
                        neutered: currentPet.neutered,
                        breed: currentPet.breed,
                        dob: currentPet.dob,
                        weight: currentPet.weight,
                        photoUrl: currentPet.photoUrl,
                        status: currentPet.status,
                        statusText: currentPet.statusText,
                        isHighlighted: currentPet.id == updatedPet.id,
                        createdAt: currentPet.createdAt,
                        updatedAt: currentPet.updatedAt
                    )
                }

                let sortedPets = sortPets(updatedPets)
                self.pets = sortedPets

                await MainActor.run {
                    NotificationCenter.default.post(name: .highlightedPetChanged, object: nil)
                    self.onPetsLoaded?(sortedPets)
                }
            } catch {
                await MainActor.run {
                    self.onError?("Failed to set main pet")
                }
            }
        }
    }

    private func sortPets(_ pets: [PetResponse]) -> [PetResponse] {
        pets.sorted {
            ($0.isHighlighted ?? false) && !($1.isHighlighted ?? false)
        }
    }
}
