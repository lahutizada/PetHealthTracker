//
//  RemindersService.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

final class RemindersService: RemindersServicing {
    static let shared = RemindersService()
    
    private init() {}
    
    func getReminders() async throws -> [ReminderResponse] {
        try await APIClient.shared.request(
            endpoint: "/reminders",
            method: "GET"
        )
    }
    
    func createReminder(requestModel: CreateReminderRequest) async throws -> ReminderResponse {
        let body = try JSONEncoder().encode(requestModel)
        
        return try await APIClient.shared.request(
            endpoint: "/reminders",
            method: "POST",
            body: body
        )
    }
    
    func updateReminder(id: String, requestModel: UpdateReminderRequest) async throws -> ReminderResponse {
        let body = try JSONEncoder().encode(requestModel)
        
        return try await APIClient.shared.request(
            endpoint: "/reminders/\(id)",
            method: "PATCH",
            body: body
        )
    }
    
    func deleteReminder(id: String) async throws {
        struct EmptyResponse: Decodable {}
        _ = try await APIClient.shared.request(
            endpoint: "/reminders/\(id)",
            method: "DELETE"
        ) as EmptyResponse
    }
}
