//
//  UpdateDewormingUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 24.03.26.
//

import Foundation

protocol UpdateDewormingUseCaseProtocol: AnyObject {
    func execute(id: String, requestModel: UpdateDewormingRequest) async throws -> DewormingRecordResponse
}

final class UpdateDewormingUseCase: UpdateDewormingUseCaseProtocol {
    
    private let service: DewormingServicing
    
    init(service: DewormingServicing = DewormingService.shared) {
        self.service = service
    }
    
    func execute(id: String, requestModel: UpdateDewormingRequest) async throws -> DewormingRecordResponse {
        try await service.updateDeworming(id: id, requestModel: requestModel)
    }
}
