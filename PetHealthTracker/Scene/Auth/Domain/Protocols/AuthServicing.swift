//
//  AuthServicing.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol AuthServicing {
    func login(email: String, password: String) async throws -> AuthResponse
}
