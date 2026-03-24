//
//  DeleteVaccinationUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 24.03.26.
//

import Foundation

protocol DeleteVaccinationUseCaseProtocol: AnyObject {
    func execute(id: String) async throws
}

final class DeleteVaccinationUseCase: DeleteVaccinationUseCaseProtocol {
    
    private let service: VaccinationsServicing
    
    init(service: VaccinationsServicing = VaccinationsService.shared) {
        self.service = service
    }
    
    func execute(id: String) async throws {
        try await service.deleteVaccination(id: id)
    }
}
