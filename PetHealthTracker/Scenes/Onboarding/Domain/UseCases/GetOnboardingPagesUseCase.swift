//
//  GetOnboardingPagesUseCase.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol GetOnboardingPagesUseCaseProtocol {
    func execute() -> [OnboardingPageEntity]
}

final class GetOnboardingPagesUseCase: GetOnboardingPagesUseCaseProtocol {
    func execute() -> [OnboardingPageEntity] {
        [
            OnboardingPageEntity(
                title: "Track their journey",
                subtitle: "Monitor every milestone from the first week to their golden years.",
                imageName: "onb1",
                buttonTitle: "Continue"
            ),
            OnboardingPageEntity(
                title: "Never miss a moment",
                subtitle: "Stay on top of vaccinations, grooming and health reminders.",
                imageName: "onb2",
                buttonTitle: "Continue"
            ),
            OnboardingPageEntity(
                title: "All records in one place",
                subtitle: "Store documents, track growth and manage their health effortlessly.",
                imageName: "onb3",
                buttonTitle: "Get Started"
            )
        ]
    }
}
