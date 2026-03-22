//
//  CreateVaccinationRequest.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 22.03.26.
//

import Foundation

struct CreateVaccinationRequest: Codable {
    let petId: String
    let vaccineType: String
    let customName: String?
    let administeredAt: String
    let nextDueAt: String?
    let notes: String?
}
