//
//  UpdateVaccinationUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 24.03.26.
//

import Foundation

protocol UpdateVaccinationUseCaseProtocol: AnyObject {
    func execute(id: String, requestModel: UpdateVaccinationRequest) async throws -> VaccinationRecordResponse
}

final class UpdateVaccinationUseCase: UpdateVaccinationUseCaseProtocol {
    
    private let service: VaccinationsServicing
    
    init(service: VaccinationsServicing = VaccinationsService.shared) {
        self.service = service
    }
    
    func execute(id: String, requestModel: UpdateVaccinationRequest) async throws -> VaccinationRecordResponse {
        try await service.updateVaccination(id: id, requestModel: requestModel)
    }
}
