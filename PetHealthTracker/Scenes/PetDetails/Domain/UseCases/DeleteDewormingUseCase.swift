//
//  DeleteDewormingUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 24.03.26.
//

import Foundation

protocol DeleteDewormingUseCaseProtocol: AnyObject {
    func execute(id: String) async throws
}

final class DeleteDewormingUseCase: DeleteDewormingUseCaseProtocol {
    
    private let service: DewormingServicing
    
    init(service: DewormingServicing = DewormingService.shared) {
        self.service = service
    }
    
    func execute(id: String) async throws {
        try await service.deleteDeworming(id: id)
    }
}
