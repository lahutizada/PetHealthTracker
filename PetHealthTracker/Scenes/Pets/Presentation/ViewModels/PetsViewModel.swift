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
                let sortedPets = response.sorted {
                    ($0.isHighlighted ?? false) && !($1.isHighlighted ?? false)
                }

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
        onLoadingStateChanged?(true)

        Task {
            do {
                _ = try await setHighlightedPetUseCase.execute(id: pet.id)
                let response = try await getPetsUseCase.execute()
                let sortedPets = response.sorted {
                    ($0.isHighlighted ?? false) && !($1.isHighlighted ?? false)
                }

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    NotificationCenter.default.post(name: .highlightedPetChanged, object: nil)
                    self.onPetsLoaded?(sortedPets)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to set main pet")
                }
            }
        }
    }
}
