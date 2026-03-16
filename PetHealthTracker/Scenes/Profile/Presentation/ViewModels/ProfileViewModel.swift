//
//  ProfileViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit

protocol ProfileViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onProfileLoaded: ((UserResponse) -> Void)? { get set }
    var onAvatarUploaded: ((String) -> Void)? { get set }
    var onLogoutSuccess: (() -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }

    func loadProfile()
    func uploadAvatar(_ image: UIImage)
    func logout()
}

final class ProfileViewModel: ProfileViewModelProtocol {

    var onLoadingStateChanged: ((Bool) -> Void)?
    var onProfileLoaded: ((UserResponse) -> Void)?
    var onAvatarUploaded: ((String) -> Void)?
    var onLogoutSuccess: (() -> Void)?
    var onError: ((String) -> Void)?

    private let getCurrentUserUseCase: GetCurrentUserUseCaseProtocol
    private let uploadAvatarUseCase: UploadAvatarUseCaseProtocol
    private let logoutUseCase: LogoutUseCaseProtocol

    init(
        getCurrentUserUseCase: GetCurrentUserUseCaseProtocol = GetCurrentUserUseCase(),
        uploadAvatarUseCase: UploadAvatarUseCaseProtocol = UploadAvatarUseCase(),
        logoutUseCase: LogoutUseCaseProtocol = LogoutUseCase()
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.uploadAvatarUseCase = uploadAvatarUseCase
        self.logoutUseCase = logoutUseCase
    }

    func loadProfile() {
        onLoadingStateChanged?(true)

        Task {
            do {
                let user = try await getCurrentUserUseCase.execute()

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onProfileLoaded?(user)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to load profile")
                }
            }
        }
    }

    func uploadAvatar(_ image: UIImage) {
        onLoadingStateChanged?(true)

        Task {
            do {
                let response = try await uploadAvatarUseCase.execute(image: image)

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onAvatarUploaded?(response.avatarUrl)
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to upload avatar")
                }
            }
        }
    }

    func logout() {
        onLoadingStateChanged?(true)

        Task {
            do {
                try await logoutUseCase.execute()

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onLogoutSuccess?()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?("Failed to log out")
                }
            }
        }
    }
}
