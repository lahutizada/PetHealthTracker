//
//  PetService.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import Foundation

final class PetService {

    static let shared = PetService()

    private init() {}

    func getPets() async throws -> [PetResponse] {
        try await APIClient.shared.request(
            endpoint: "/pets",
            method: "GET",
            requiresAuth: true
        )
    }

    func createPet(_ requestModel: CreatePetRequest) async throws -> PetResponse {
        let body = try JSONEncoder().encode(requestModel)

        return try await APIClient.shared.request(
            endpoint: "/pets",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func setHighlightedPet(id: String) async throws -> PetResponse {
        try await APIClient.shared.request(
            endpoint: "/pets/\(id)/highlight",
            method: "PATCH",
            requiresAuth: true
        )
    }
}
