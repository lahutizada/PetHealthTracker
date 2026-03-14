//
//  OnboardingPageViewModel.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 14.03.26.
//

import Foundation

protocol OnboardingPageViewModelProtocol {
    var title: String { get }
    var subtitle: String { get }
    var imageName: String { get }
    var buttonTitle: String { get }
}

final class OnboardingPageViewModel: OnboardingPageViewModelProtocol {
    private let page: OnboardingPageEntity

    init(page: OnboardingPageEntity) {
        self.page = page
    }

    var title: String { page.title }
    var subtitle: String { page.subtitle }
    var imageName: String { page.imageName }
    var buttonTitle: String { page.buttonTitle }
}
