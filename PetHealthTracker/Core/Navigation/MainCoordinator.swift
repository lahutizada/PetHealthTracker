//
//  MainCoordinator.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import UIKit

final class MainCoordinator: Coordinator {

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let tabBarController = MainTabBarController()
        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }
}
