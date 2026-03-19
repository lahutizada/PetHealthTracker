//
//  DeleteReminderUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

protocol DeleteReminderUseCaseProtocol {
    func execute(id: String) async throws
}

final class DeleteReminderUseCase: DeleteReminderUseCaseProtocol {
    
    private let remindersService: RemindersServicing
    
    init(remindersService: RemindersServicing = RemindersService.shared) {
        self.remindersService = remindersService
    }
    
    func execute(id: String) async throws {
        try await remindersService.deleteReminder(id: id)
    }
}
