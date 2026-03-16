//
//  AuthServicing.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol AuthServicing {
    func login(email: String, password: String) async throws -> AuthResponse
    func register(name: String, email: String, password: String) async throws -> AuthResponse
    func forgotPassword(email: String) async throws
    func resetPassword(token: String, newPassword: String) async throws
    func me() async throws -> UserResponse
    func logout() async throws
}
