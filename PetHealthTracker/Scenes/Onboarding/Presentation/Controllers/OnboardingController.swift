//
//  OnboardingController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 05.03.26.
//

import UIKit

final class OnboardingController: UIPageViewController {

    var onFinish: (() -> Void)?

    private let viewModel: OnboardingViewModelProtocol

    private lazy var controllers: [OnboardingPageController] = {
        (0..<viewModel.pagesCount).map { index in
            let vc = OnboardingPageController(
                viewModel: viewModel.pageViewModel(at: index)
            )
            vc.total = viewModel.pagesCount
            vc.index = index
            vc.onContinue = { [weak self] in
                self?.goNext()
            }
            return vc
        }
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.setTitleColor(.onboardingGray, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipTapped), for: .touchUpInside)
        return button
    }()

    init(viewModel: OnboardingViewModelProtocol = OnboardingViewModel()) {
        self.viewModel = viewModel
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        setViewControllers([controllers[0]], direction: .forward, animated: false)

        configureUI()
        configureConstraints()
        updateUI(for: 0)
    }

    private func configureUI() {
        view.addSubview(skipButton)
    }

    private func configureConstraints() {
        NSLayoutConstraint.activate([
            skipButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18)
        ])
    }

    private func updateUI(for index: Int) {
        viewModel.currentIndex = index
        skipButton.isHidden = viewModel.shouldHideSkipButton(at: index)

        let vc = controllers[index]
        vc.index = index
        vc.total = viewModel.pagesCount
    }

    private func goNext() {
        if let nextIndex = viewModel.nextIndex() {
            let nextVC = controllers[nextIndex]
            setViewControllers([nextVC], direction: .forward, animated: true)
            updateUI(for: nextIndex)
        } else {
            finishOnboarding()
        }
    }

    @objc private func skipTapped() {
        finishOnboarding()
    }

    private func finishOnboarding() {
        viewModel.completeOnboarding()
        onFinish?()
    }
}

extension OnboardingController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? OnboardingPageController,
              let index = controllers.firstIndex(of: vc),
              index > 0
        else { return nil }

        return controllers[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let vc = viewController as? OnboardingPageController,
              let index = controllers.firstIndex(of: vc),
              index < controllers.count - 1
        else { return nil }

        return controllers[index + 1]
    }
}

extension OnboardingController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentVC = viewControllers?.first as? OnboardingPageController,
              let index = controllers.firstIndex(of: currentVC)
        else { return }

        updateUI(for: index)
    }
}
