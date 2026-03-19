//
//  UpdateReminderRequest.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

struct UpdateReminderRequest: Codable {
    let title: String?
    let notes: String?
    let dueDate: String?
    let type: String?
    let completed: Bool?
    let petId: String?
}
