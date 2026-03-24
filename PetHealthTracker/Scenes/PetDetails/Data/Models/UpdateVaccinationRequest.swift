//
//  UpdateVaccinationRequest.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 24.03.26.
//

import Foundation

struct UpdateVaccinationRequest: Encodable {
    let petId: String
    let vaccineType: String
    let customName: String?
    let administeredAt: String
    let nextDueAt: String?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case petId
        case vaccineType
        case customName
        case administeredAt
        case nextDueAt
        case notes
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(petId, forKey: .petId)
        try container.encode(vaccineType, forKey: .vaccineType)
        try container.encodeIfPresent(customName, forKey: .customName)
        try container.encode(administeredAt, forKey: .administeredAt)
        try container.encode(nextDueAt, forKey: .nextDueAt) // <- encode null too
        try container.encodeIfPresent(notes, forKey: .notes)
    }
}
