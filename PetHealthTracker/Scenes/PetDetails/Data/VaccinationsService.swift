//
//  VaccinationsService.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

final class VaccinationsService: VaccinationsServicing {
    
    static let shared = VaccinationsService()
    
    private init() {}
    
    func getVaccinations(petId: String) async throws -> [VaccinationRecordResponse] {
        try await APIClient.shared.request(
            endpoint: "/vaccinations/pet/\(petId)",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func createVaccination(_ requestModel: CreateVaccinationRequest) async throws -> VaccinationRecordResponse {
        let body = try JSONEncoder().encode(requestModel)
        
        return try await APIClient.shared.request(
            endpoint: "/vaccinations",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func deleteVaccination(id: String) async throws {
        let _: DeleteResponse = try await APIClient.shared.request(
            endpoint: "/vaccinations/\(id)",
            method: "DELETE",
            requiresAuth: true
        )
    }
}
