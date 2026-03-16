//
//  OnboardingManager.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 05.03.26.
//

import Foundation

final class OnboardingManager: OnboardingStorageProtocol {

    static let shared = OnboardingManager()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }

    private init() {}

    var hasSeenOnboarding: Bool {
        UserDefaults.standard.bool(forKey: Keys.hasSeenOnboarding)
    }

    func markAsSeen() {
        UserDefaults.standard.set(true, forKey: Keys.hasSeenOnboarding)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: Keys.hasSeenOnboarding)
    }
}
