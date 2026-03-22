//
//  GetDewormingUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

protocol GetDewormingUseCaseProtocol {
    func execute(petId: String) async throws -> [DewormingRecordResponse]
}

final class GetDewormingUseCase: GetDewormingUseCaseProtocol {
    
    private let service: DewormingServicing
    
    init(service: DewormingServicing = DewormingService.shared) {
        self.service = service
    }
    
    func execute(petId: String) async throws -> [DewormingRecordResponse] {
        try await service.getDeworming(petId: petId)
    }
}
