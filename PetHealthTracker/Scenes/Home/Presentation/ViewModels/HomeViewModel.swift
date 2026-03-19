//
//  HomeViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol HomeViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onHomeLoaded: ((HomeViewData) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    
    func loadHome()
    func reloadHome()
}

final class HomeViewModel: HomeViewModelProtocol {
    
    var onLoadingStateChanged: ((Bool) -> Void)?
    var onHomeLoaded: ((HomeViewData) -> Void)?
    var onError: ((String) -> Void)?
    
    private let getHomeDataUseCase: GetHomeDataUseCaseProtocol
    
    init(getHomeDataUseCase: GetHomeDataUseCaseProtocol = GetHomeDataUseCase()) {
        self.getHomeDataUseCase = getHomeDataUseCase
    }
    
    func loadHome() {
        fetchHome()
    }
    
    func reloadHome() {
        fetchHome()
    }
    
    private func fetchHome() {
        onLoadingStateChanged?(true)
        
        Task {
            do {
                let (user, pets) = try await getHomeDataUseCase.execute()
                let viewData = makeViewData(user: user, pets: pets)
                
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onHomeLoaded?(viewData)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to load home data")
                }
            }
        }
    }
    
    private func makeViewData(user: UserResponse, pets: [PetResponse]) -> HomeViewData {
        let displayName: String = {
            let cleanedName = user.name?.trimmingCharacters(in: .whitespacesAndNewlines)
            if let cleanedName, !cleanedName.isEmpty {
                return cleanedName.components(separatedBy: " ").first ?? "Friend"
            }
            return user.email.components(separatedBy: "@").first ?? "Friend"
        }()
        
        let highlightedPet = pets.first(where: { $0.isHighlighted == true }) ?? pets.first
        
        guard let pet = highlightedPet else {
            return HomeViewData(
                greetingText: "Hello, \(displayName) 👋",
                petName: "No pets yet",
                petInfo: "Add your first pet to get started",
                petStatusText: "Ready",
                petsCountText: "0",
                speciesText: "—",
                mainPetText: "—",
                petPhotoURL: nil,
                currentPet: nil
            )
        }
        
        let speciesText = pet.species.uppercased() == "CAT" ? "Cat" : "Dog"
        let breedText = pet.breed ?? "Unknown breed"
        let statusText = pet.weight == nil ? "Check weight" : "Up to date"
        
        return HomeViewData(
            greetingText: "Hello, \(displayName) 👋",
            petName: pet.name,
            petInfo: "\(speciesText) • \(breedText)",
            petStatusText: statusText,
            petsCountText: "\(pets.count)",
            speciesText: speciesText,
            mainPetText: pet.name,
            petPhotoURL: pet.photoUrl,
            currentPet: pet
        )
    }
}
