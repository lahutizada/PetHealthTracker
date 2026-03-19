//
//  UpdateReminderUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

protocol UpdateReminderUseCaseProtocol {
    func execute(id: String, requestModel: UpdateReminderRequest) async throws -> ReminderResponse
}

final class UpdateReminderUseCase: UpdateReminderUseCaseProtocol {
    
    private let remindersService: RemindersServicing
    
    init(remindersService: RemindersServicing = RemindersService.shared) {
        self.remindersService = remindersService
    }
    
    func execute(id: String, requestModel: UpdateReminderRequest) async throws -> ReminderResponse {
        try await remindersService.updateReminder(id: id, requestModel: requestModel)
    }
}
