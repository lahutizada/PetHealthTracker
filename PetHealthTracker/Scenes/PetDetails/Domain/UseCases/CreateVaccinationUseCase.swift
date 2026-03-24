//
//  CreateVaccinationUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import Foundation

protocol CreateVaccinationUseCaseProtocol: AnyObject {
    func execute(requestModel: CreateVaccinationRequest) async throws -> VaccinationRecordResponse
}

final class CreateVaccinationUseCase: CreateVaccinationUseCaseProtocol {
    
    private let service: VaccinationsServicing
    
    init(service: VaccinationsServicing = VaccinationsService.shared) {
        self.service = service
    }
    
    func execute(requestModel: CreateVaccinationRequest) async throws -> VaccinationRecordResponse {
        try await service.createVaccination(requestModel)
    }
}
