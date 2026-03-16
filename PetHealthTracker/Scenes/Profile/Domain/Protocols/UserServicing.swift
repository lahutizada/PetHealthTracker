//
//  UserServicing.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit

protocol UserServicing {
    func uploadAvatar(image: UIImage) async throws -> AvatarUploadResponse
    func updateProfile(name: String) async throws -> UserResponse
}
