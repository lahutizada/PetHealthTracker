//
//  EditProfileViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol EditProfileViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onProfileUpdated: ((UserResponse) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    var onSuccess: ((String?) -> Void)? { get set }

    func saveProfile(name: String?)
    func clearMessages()
}

final class EditProfileViewModel: EditProfileViewModelProtocol {

    var onLoadingStateChanged: ((Bool) -> Void)?
    var onProfileUpdated: ((UserResponse) -> Void)?
    var onError: ((String?) -> Void)?
    var onSuccess: ((String?) -> Void)?

    private let updateProfileUseCase: UpdateProfileUseCaseProtocol

    init(updateProfileUseCase: UpdateProfileUseCaseProtocol = UpdateProfileUseCase()) {
        self.updateProfileUseCase = updateProfileUseCase
    }

    func saveProfile(name: String?) {
        clearMessages()

        let cleanName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !cleanName.isEmpty else {
            onError?("Full name is required")
            return
        }

        guard cleanName.count >= 2 else {
            onError?("Name must be at least 2 characters")
            return
        }

        onLoadingStateChanged?(true)

        Task {
            do {
                let updatedUser = try await updateProfileUseCase.execute(name: cleanName)

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onSuccess?("Profile updated")
                    self.onProfileUpdated?(updatedUser)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to update profile")
                }
            }
        }
    }

    func clearMessages() {
        onError?(nil)
        onSuccess?(nil)
    }
}
