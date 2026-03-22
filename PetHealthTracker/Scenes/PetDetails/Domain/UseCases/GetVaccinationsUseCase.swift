//
//  GetVaccinationsUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

protocol GetVaccinationsUseCaseProtocol {
    func execute(petId: String) async throws -> [VaccinationRecordResponse]
}

final class GetVaccinationsUseCase: GetVaccinationsUseCaseProtocol {
    
    private let service: VaccinationsServicing
    
    init(service: VaccinationsServicing = VaccinationsService.shared) {
        self.service = service
    }
    
    func execute(petId: String) async throws -> [VaccinationRecordResponse] {
        try await service.getVaccinations(petId: petId)
    }
}
