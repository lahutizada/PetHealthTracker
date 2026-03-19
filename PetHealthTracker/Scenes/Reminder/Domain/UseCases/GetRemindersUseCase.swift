//
//  GetRemindersUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

protocol GetRemindersUseCaseProtocol {
    func execute() async throws -> [ReminderResponse]
}

final class GetRemindersUseCase: GetRemindersUseCaseProtocol {
    
    private let remindersService: RemindersServicing
    
    init(remindersService: RemindersServicing = RemindersService.shared) {
        self.remindersService = remindersService
    }
    
    func execute() async throws -> [ReminderResponse] {
        try await remindersService.getReminders()
    }
}
