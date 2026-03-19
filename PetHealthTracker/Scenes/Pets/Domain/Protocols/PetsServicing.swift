//
//  PetsServicing.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit

protocol PetsServicing {
    func getPets() async throws -> [PetResponse]
    func getPet(id: String) async throws -> PetResponse
    func createPet(_ requestModel: CreatePetRequest) async throws -> PetResponse
    func updatePet(id: String, requestModel: CreatePetRequest) async throws -> PetResponse
    func deletePet(id: String) async throws
    func setHighlightedPet(id: String) async throws -> PetResponse
    func uploadPetPhoto(petId: String, image: UIImage) async throws -> PetResponse
    func deletePetPhoto(id: String) async throws -> PetResponse
}
