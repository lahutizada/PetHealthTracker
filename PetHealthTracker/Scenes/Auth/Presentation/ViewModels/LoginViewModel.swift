//
//  LoginViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol LoginViewModelProtocol: AnyObject {
    var onLoadingStateChanged: ((Bool) -> Void)? { get set }
    var onError: ((String?) -> Void)? { get set }
    var onLoginSuccess: (() -> Void)? { get set }

    func login(email: String?, password: String?)
    func loginWithGoogle(idToken: String)
    func clearError()
}

final class LoginViewModel: LoginViewModelProtocol {

    var onLoadingStateChanged: ((Bool) -> Void)?
    var onError: ((String?) -> Void)?
    var onLoginSuccess: (() -> Void)?

    private let loginUseCase: LoginUseCaseProtocol
    private let googleLoginUseCase: GoogleLoginUseCaseProtocol

    init(
        loginUseCase: LoginUseCaseProtocol = LoginUseCase(),
        googleLoginUseCase: GoogleLoginUseCaseProtocol = GoogleLoginUseCase()
    ) {
        self.loginUseCase = loginUseCase
        self.googleLoginUseCase = googleLoginUseCase
    }

    func login(email: String?, password: String?) {
        clearError()

        let cleanEmail = email?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let cleanPassword = password?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !cleanEmail.isEmpty, !cleanPassword.isEmpty else {
            onError?("Email and password are required")
            return
        }

        guard cleanEmail.contains("@"), cleanEmail.contains(".") else {
            onError?("Incorrect email format")
            return
        }

        onLoadingStateChanged?(true)

        Task {
            do {
                let response = try await loginUseCase.execute(
                    email: cleanEmail,
                    password: cleanPassword
                )

                SessionManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onLoginSuccess?()
                }
            } catch {
                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onError?(AuthErrorAdapter.message(from: error))
                }
            }
        }
    }

    func loginWithGoogle(idToken: String) {
        clearError()
        onLoadingStateChanged?(true)

        Task {
            do {
                let response = try await googleLoginUseCase.execute(idToken: idToken)

                SessionManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )

                await MainActor.run {
                    self.onLoadingStateChanged?(false)
                    self.onLoginSuccess?()
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
