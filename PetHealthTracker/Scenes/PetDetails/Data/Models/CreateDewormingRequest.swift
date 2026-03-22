//
//  CreateDewormingRequest.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

struct CreateDewormingRequest: Codable {
    let petId: String
    let productName: String?
    let administeredAt: String
    let nextDueAt: String?
    let notes: String?
}
