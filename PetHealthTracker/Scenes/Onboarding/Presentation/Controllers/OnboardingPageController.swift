//
//  OnboardingPageController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 05.03.26.
//

import UIKit

final class OnboardingPageController: BaseController {

    var onContinue: (() -> Void)?

    var index: Int = 0 {
        didSet { pageIndicator.current = index }
    }

    var total: Int = 0 {
        didSet { pageIndicator.pages = total }
    }

    private let viewModel: OnboardingPageViewModelProtocol

    private lazy var heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: viewModel.imageName)
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private lazy var bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var pageIndicator: OnboardingPageIndicator = {
        let view = OnboardingPageIndicator()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.title
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.subtitle
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return label
    }()

    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(viewModel.buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 27
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        return button
    }()

    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, continueButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(viewModel: OnboardingPageViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(heroImageView)
        view.addSubview(bottomContainer)
        bottomContainer.addSubview(pageIndicator)
        bottomContainer.addSubview(contentStack)
    }

    override func configureConstraints() {
        NSLayoutConstraint.activate([
            heroImageView.topAnchor.constraint(equalTo: view.topAnchor),
            heroImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContainer.heightAnchor.constraint(equalToConstant: 320),

            heroImageView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 40),

            pageIndicator.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 18),
            pageIndicator.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),

            contentStack.topAnchor.constraint(equalTo: pageIndicator.bottomAnchor, constant: 18),
            contentStack.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 30),
            contentStack.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -30),
            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: bottomContainer.bottomAnchor, constant: -24),

            continueButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    @objc private func continueTapped() {
        onContinue?()
    }
}
