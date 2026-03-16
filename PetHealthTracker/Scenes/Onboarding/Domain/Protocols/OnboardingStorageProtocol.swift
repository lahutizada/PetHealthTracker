//
//  OnboardingStorageProtocol.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol OnboardingStorageProtocol {
    var hasSeenOnboarding: Bool { get }
    func markAsSeen()
    func reset()
}
