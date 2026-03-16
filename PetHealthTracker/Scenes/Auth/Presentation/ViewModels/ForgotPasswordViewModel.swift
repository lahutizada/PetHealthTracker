//
//  ForgotPasswordViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol ForgotPasswordViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    var onSuccess: ((String?) -> Void)? { get set }

    func sendResetLink(email: String?)
    func clearMessages()
}

final class ForgotPasswordViewModel: ForgotPasswordViewModelProtocol {

    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String?) -> Void)?
    var onSuccess: ((String?) -> Void)?

    private let forgotPasswordUseCase: ForgotPasswordUseCaseProtocol

    init(forgotPasswordUseCase: ForgotPasswordUseCaseProtocol = ForgotPasswordUseCase()) {
        self.forgotPasswordUseCase = forgotPasswordUseCase
    }

    func sendResetLink(email: String?) {
        clearMessages()

        let cleanEmail = email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !cleanEmail.isEmpty else {
            onError?("Email is required")
            return
        }

        guard cleanEmail.contains("@"), cleanEmail.contains(".") else {
            onError?("Incorrect email format")
            return
        }

        onLoadingStateChanged?(true)

        Task {
            do {
                try await forgotPasswordUseCase.execute(email: cleanEmail)

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onSuccess?("Reset link sent")
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
