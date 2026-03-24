//
//  DewormingService.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

final class DewormingService: DewormingServicing {
    
    static let shared = DewormingService()
    
    private init() {}
    
    func getDeworming(petId: String) async throws -> [DewormingRecordResponse] {
        try await APIClient.shared.request(
            endpoint: "/deworming/pet/\(petId)",
            method: "GET",
            requiresAuth: true
        )
    }
    
    func createDeworming(_ requestModel: CreateDewormingRequest) async throws -> DewormingRecordResponse {
        let body = try JSONEncoder().encode(requestModel)
        
        return try await APIClient.shared.request(
            endpoint: "/deworming",
            method: "POST",
            body: body,
            requiresAuth: true
        )
    }
    
    func updateDeworming(id: String, requestModel: UpdateDewormingRequest) async throws -> DewormingRecordResponse {
        let body = try JSONEncoder().encode(requestModel)
        
        return try await APIClient.shared.request(
            endpoint: "/deworming/\(id)",
            method: "PATCH",
            body: body,
            requiresAuth: true
        )
    }
    
    func deleteDeworming(id: String) async throws {
        let _: DeleteResponse = try await APIClient.shared.request(
            endpoint: "/deworming/\(id)",
            method: "DELETE",
            requiresAuth: true
        )
    }
}
