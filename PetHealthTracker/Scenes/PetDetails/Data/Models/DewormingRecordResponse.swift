//
//  DewormingRecordResponse.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

struct DewormingRecordResponse: Codable {
    let id: String
    let petId: String
    let productName: String?
    let administeredAt: String
    let nextDueAt: String?
    let notes: String?
}
