//
//  UpdateProfileUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol UpdateProfileUseCaseProtocol {
    func execute(name: String) async throws -> UserResponse
}

final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {

    private let usersService: UserServicing

    init(usersService: UserServicing = UsersService.shared) {
        self.usersService = usersService
    }

    func execute(name: String) async throws -> UserResponse {
        try await usersService.updateProfile(name: name)
    }
}
