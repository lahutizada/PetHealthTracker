//
//  CreatePetRequest.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import Foundation

struct CreatePetRequest: Codable {
    let species: String
    let name: String
    let sex: String
    let neutered: Bool
    let breed: String?
    let dob: String?
}
