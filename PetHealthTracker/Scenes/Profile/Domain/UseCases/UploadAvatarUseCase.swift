//
//  UploadAvatarUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit

protocol UploadAvatarUseCaseProtocol {
    func execute(image: UIImage) async throws -> AvatarUploadResponse
}

final class UploadAvatarUseCase: UploadAvatarUseCaseProtocol {

    private let usersService: UserServicing

    init(usersService: UserServicing = UsersService.shared) {
        self.usersService = usersService
    }

    func execute(image: UIImage) async throws -> AvatarUploadResponse {
        try await usersService.uploadAvatar(image: image)
    }
}
