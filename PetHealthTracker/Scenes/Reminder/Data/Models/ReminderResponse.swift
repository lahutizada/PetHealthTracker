//
//  ReminderResponse.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import Foundation

struct ReminderResponse: Codable {
    let id: String
    let petId: String?
    let title: String
    let notes: String?
    let dueDate: String?
    let type: String?
    let completed: Bool
    let petName: String?
    let petPhotoUrl: String?
}
