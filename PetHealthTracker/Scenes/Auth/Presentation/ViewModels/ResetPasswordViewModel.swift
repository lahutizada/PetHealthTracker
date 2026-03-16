//
//  ResetPasswordViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol ResetPasswordViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    var onSuccess: ((String?) -> Void)? { get set }
    var onResetSuccess: (() -> Void)? { get set }

    func resetPassword(token: String, password: String?, confirmPassword: String?)
    func clearMessages()
}

final class ResetPasswordViewModel: ResetPasswordViewModelProtocol {

    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String?) -> Void)?
    var onSuccess: ((String?) -> Void)?
    var onResetSuccess: (() -> Void)?

    private let resetPasswordUseCase: ResetPasswordUseCaseProtocol

    init(resetPasswordUseCase: ResetPasswordUseCaseProtocol = ResetPasswordUseCase()) {
        self.resetPasswordUseCase = resetPasswordUseCase
    }

    func resetPassword(token: String, password: String?, confirmPassword: String?) {
        clearMessages()

        let cleanPassword = password?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanConfirmPassword = confirmPassword?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !cleanPassword.isEmpty, !cleanConfirmPassword.isEmpty else {
            onError?("All fields are required")
            return
        }

        guard cleanPassword.count >= 8 else {
            onError?("Password must be at least 8 characters")
            return
        }

        guard cleanPassword == cleanConfirmPassword else {
            onError?("Passwords do not match")
            return
        }

        onLoadingStateChanged?(true)

        Task {
            do {
                try await resetPasswordUseCase.execute(token: token, newPassword: cleanPassword)

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onSuccess?("Password has been reset successfully")
                    self.onResetSuccess?()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?(AuthErrorAdapter.message(from: error))
                }
            }
        }
    }

    func clearMessages() {
        onError?(nil)
        onSuccess?(nil)
    }
}
