//
//  UserResponse.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import Foundation

struct UserResponse: Codable {
    let sub: String
    let email: String
    let name: String?
    let avatarUrl: String?
    let highlightedPetId: String?
}
