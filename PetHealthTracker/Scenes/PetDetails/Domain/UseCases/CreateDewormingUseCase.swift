//
//  CreateDewormingUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import Foundation

protocol CreateDewormingUseCaseProtocol: AnyObject {
    func execute(requestModel: CreateDewormingRequest) async throws -> DewormingRecordResponse
}

final class CreateDewormingUseCase: CreateDewormingUseCaseProtocol {
    
    private let service: DewormingServicing
    
    init(service: DewormingServicing = DewormingService.shared) {
        self.service = service
    }
    
    func execute(requestModel: CreateDewormingRequest) async throws -> DewormingRecordResponse {
        try await service.createDeworming(requestModel)
    }
}
