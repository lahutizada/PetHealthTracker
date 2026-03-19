//
//  AppCoordinator.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import UIKit

final class AppCoordinator {
    
    private let window: UIWindow
    private let navigationController = UINavigationController()
    
    private var onboardingCoordinator: OnboardingCoordinator?
    private var authCoordinator: AuthCoordinator?
    private var mainCoordinator: MainCoordinator?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        
        if !OnboardingManager.shared.hasSeenOnboarding {
            showOnboarding()
        } else if SessionManager.shared.isLoggedIn {
            showMain()
        } else {
            showAuth()
        }
    }
    
    func showOnboarding() {
        let coordinator = OnboardingCoordinator(navigationController: navigationController)
        
        coordinator.onFinish = { [weak self] in
            OnboardingManager.shared.markAsSeen()
            self?.showAuth()
        }
        
        onboardingCoordinator = coordinator
        authCoordinator = nil
        mainCoordinator = nil
        
        coordinator.start()
    }
    
    func showAuth() {
        let coordinator = AuthCoordinator(navigationController: navigationController)
        
        coordinator.onAuthSuccess = { [weak self] in
            self?.showMain()
        }
        
        authCoordinator = coordinator
        onboardingCoordinator = nil
        mainCoordinator = nil
        
        coordinator.start()
    }
    
    func showMain() {
        let coordinator = MainCoordinator(navigationController: navigationController)
        
        mainCoordinator = coordinator
        onboardingCoordinator = nil
        authCoordinator = nil
        
        coordinator.start()
    }
    
    func showLogin() {
        onboardingCoordinator = nil
        mainCoordinator = nil
        
        let coordinator = AuthCoordinator(navigationController: navigationController)
        
        coordinator.onAuthSuccess = { [weak self] in
            self?.showMain()
        }
        
        authCoordinator = coordinator
        coordinator.start()
    }
    
    func showResetPassword(token: String) {
        let resetVC = ResetPasswordController(token: token)
        navigationController.setViewControllers([resetVC], animated: false)
    }
    
    func logout() {
        SessionManager.shared.clearSession()
        showAuth()
    }
}
