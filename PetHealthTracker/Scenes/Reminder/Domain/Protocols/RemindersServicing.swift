//
//  RemindersServicing.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

protocol RemindersServicing {
    func getReminders() async throws -> [ReminderResponse]
    func createReminder(requestModel: CreateReminderRequest) async throws -> ReminderResponse
    func updateReminder(id: String, requestModel: UpdateReminderRequest) async throws -> ReminderResponse
    func deleteReminder(id: String) async throws
}
