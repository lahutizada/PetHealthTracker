//
//  CompleteOnboardingUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol CompleteOnboardingUseCaseProtocol {
    func execute()
}

final class CompleteOnboardingUseCase: CompleteOnboardingUseCaseProtocol {
    private let storage: OnboardingStorageProtocol

    init(storage: OnboardingStorageProtocol) {
        self.storage = storage
    }

    func execute() {
        storage.markAsSeen()
    }
}
