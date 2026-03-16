//
//  RegisterViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import Foundation

protocol RegisterViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    var onRegisterSuccess: (() -> Void)? { get set }

    func register(name: String?, email: String?, password: String?, confirmPassword: String?)
    func clearError()
}

final class RegisterViewModel: RegisterViewModelProtocol {

    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String?) -> Void)?
    var onRegisterSuccess: (() -> Void)?

    private let registerUseCase: RegisterUseCaseProtocol

    init(registerUseCase: RegisterUseCaseProtocol = RegisterUseCase()) {
        self.registerUseCase = registerUseCase
    }

    func register(name: String?, email: String?, password: String?, confirmPassword: String?) {
        clearError()

        let cleanName = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanEmail = email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanPassword = password?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanConfirmPassword = confirmPassword?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !cleanName.isEmpty, !cleanEmail.isEmpty, !cleanPassword.isEmpty, !cleanConfirmPassword.isEmpty else {
            onError?("All fields are required")
            return
        }

        guard cleanEmail.contains("@"), cleanEmail.contains(".") else {
            onError?("Incorrect email format")
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
                let response = try await registerUseCase.execute(
                    name: cleanName,
                    email: cleanEmail,
                    password: cleanPassword
                )

                SessionManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onRegisterSuccess?()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?(AuthErrorAdapter.message(from: error))
                }
            }
        }
    }

    func clearError() {
        onError?(nil)
    }
}
