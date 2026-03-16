//
//  PetDetailsViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 17.03.26.
//

import Foundation

protocol PetDetailsViewModelProtocol: AnyObject {

    var onPetLoaded: ((PetResponse) -> Void)? { get set }
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    func loadPet()
    func setMainPet()
}

final class PetDetailsViewModel: PetDetailsViewModelProtocol {

    var onPetLoaded: ((PetResponse) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    private let petId: String

    private let getPetDetailsUseCase: GetPetDetailsUseCaseProtocol
    private let setHighlightedPetUseCase: SetHighlightedPetUseCaseProtocol

    init(
        petId: String,
        getPetDetailsUseCase: GetPetDetailsUseCaseProtocol = GetPetDetailsUseCase(),
        setHighlightedPetUseCase: SetHighlightedPetUseCaseProtocol = SetHighlightedPetUseCase()
    ) {
        self.petId = petId
        self.getPetDetailsUseCase = getPetDetailsUseCase
        self.setHighlightedPetUseCase = setHighlightedPetUseCase
    }

    func loadPet() {

        onLoadingStateChanged?(true)

        Task {

            do {

                let pet = try await getPetDetailsUseCase.execute(id: petId)

                await MainActor.run {

                    self.onLoadingStateChanged?(false)
                    self.onPetLoaded?(pet)

                }

            } catch {

                await MainActor.run {

                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to load pet")

                }

            }

        }

    }

    func setMainPet() {

        onLoadingStateChanged?(true)

        Task {

            do {

                _ = try await setHighlightedPetUseCase.execute(id: petId)

                let pet = try await getPetDetailsUseCase.execute(id: petId)

                await MainActor.run {

                    self.onLoadingStateChanged?(false)
                    self.onPetLoaded?(pet)

                    NotificationCenter.default.post(
                        name: .highlightedPetChanged,
                        object: nil
                    )

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
