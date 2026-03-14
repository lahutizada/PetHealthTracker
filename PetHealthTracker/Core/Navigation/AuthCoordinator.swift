//
//  AuthCoordinator.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import UIKit

final class AuthCoordinator: Coordinator {

    let navigationController: UINavigationController
    var onAuthSuccess: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showLogin()
    }

    func showLogin() {
        let controller = LoginController()

        controller.onOpenRegister = { [weak self] in
            self?.showRegister()
        }

        controller.onOpenForgotPassword = { [weak self] in
            self?.showForgotPassword()
        }

        controller.onLoginSuccess = { [weak self] in
            self?.onAuthSuccess?()
        }

        navigationController.setViewControllers([controller], animated: false)
    }

    func showRegister() {
        let controller = RegisterController()
        navigationController.pushViewController(controller, animated: true)
    }

    func showForgotPassword() {
        let controller = ForgotPasswordController()
        navigationController.pushViewController(controller, animated: true)
    }
}
