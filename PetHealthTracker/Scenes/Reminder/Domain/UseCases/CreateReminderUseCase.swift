//
//  CreateReminderUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

protocol CreateReminderUseCaseProtocol {
    func execute(requestModel: CreateReminderRequest) async throws -> ReminderResponse
}

final class CreateReminderUseCase: CreateReminderUseCaseProtocol {
    
    private let remindersService: RemindersServicing
    
    init(remindersService: RemindersServicing = RemindersService.shared) {
        self.remindersService = remindersService
    }
    
    func execute(requestModel: CreateReminderRequest) async throws -> ReminderResponse {
        try await remindersService.createReminder(requestModel: requestModel)
    }
}
