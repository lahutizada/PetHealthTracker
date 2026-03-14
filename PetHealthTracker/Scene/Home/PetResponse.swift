//
//  PetResponse.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import Foundation

struct PetResponse: Codable {
    let id: String
    let userId: String
    let species: String
    let name: String
    let sex: String
    let neutered: Bool
    let breed: String?
    let dob: String?
    let isHighlighted: Bool?
    let createdAt: String
    let updatedAt: String
}

enum PetFormMode {
    case create
    case edit(PetResponse)
}
