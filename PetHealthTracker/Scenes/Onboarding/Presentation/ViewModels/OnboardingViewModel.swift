//
//  OnboardingViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol OnboardingViewModelProtocol: AnyObject {
    var currentIndex: Int { get set }
    var pagesCount: Int { get }

    func pageViewModel(at index: Int) -> OnboardingPageViewModel
    func shouldHideSkipButton(at index: Int) -> Bool
    func nextIndex() -> Int?
    func completeOnboarding()
}

final class OnboardingViewModel: OnboardingViewModelProtocol {

    private let getPagesUseCase: GetOnboardingPagesUseCaseProtocol
    private let completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol
    private let pages: [OnboardingPageEntity]

    var currentIndex: Int = 0

    init(
        getPagesUseCase: GetOnboardingPagesUseCaseProtocol = GetOnboardingPagesUseCase(),
        completeOnboardingUseCase: CompleteOnboardingUseCaseProtocol = CompleteOnboardingUseCase(
            storage: OnboardingManager.shared
        )
    ) {
        self.getPagesUseCase = getPagesUseCase
        self.completeOnboardingUseCase = completeOnboardingUseCase
        self.pages = getPagesUseCase.execute()
    }

    var pagesCount: Int {
        pages.count
    }

    func pageViewModel(at index: Int) -> OnboardingPageViewModel {
        OnboardingPageViewModel(page: pages[index])
    }

    func shouldHideSkipButton(at index: Int) -> Bool {
        index == pages.count - 1
    }

    func nextIndex() -> Int? {
        let next = currentIndex + 1
        return next < pages.count ? next : nil
    }

    func completeOnboarding() {
        completeOnboardingUseCase.execute()
    }
}
