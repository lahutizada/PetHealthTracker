//
//  OnboardingCoordinator.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import UIKit

final class OnboardingCoordinator: Coordinator {

    let navigationController: UINavigationController
    var onFinish: (() -> Void)?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let controller = OnboardingController()
        controller.onFinish = { [weak self] in
            self?.onFinish?()
        }

        navigationController.setViewControllers([controller], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}
