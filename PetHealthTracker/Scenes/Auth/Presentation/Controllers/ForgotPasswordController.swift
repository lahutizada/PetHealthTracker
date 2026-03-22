//
//  ForgotPasswordController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 07.03.26.
//

import UIKit

final class ForgotPasswordController: BaseController {
    
    private let viewModel: ForgotPasswordViewModelProtocol

    init(viewModel: ForgotPasswordViewModelProtocol = DIContainer.shared.makeForgotPasswordViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Constants
    
    private let heroHeight: CGFloat = 700
    private let maxImageTranslate: CGFloat = 36
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsVerticalScrollIndicator = false
        scroll.alwaysBounceVertical = false
        scroll.bounces = false
        scroll.contentInsetAdjustmentBehavior = .never
        scroll.delegate = self
        return scroll
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var heroContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var heroImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "forgotPasswordHero")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 32
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.06
        view.layer.shadowRadius = 20
        view.layer.shadowOffset = CGSize(width: 0, height: -4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        view.layer.cornerRadius = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Forgot Password?"
        label.font = .systemFont(ofSize: 28, weight: .heavy)
        label.textColor = .onboardingBlack
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter your email address and we’ll send you a link to reset your password."
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email Address"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "example@email.com"
        textField.borderStyle = .none
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 27
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.setLeftPadding(18)
        textField.addTarget(self, action: #selector(clearStatus), for: .editingChanged)
        return textField
    }()
    
    private lazy var statusView = StatusMessageView()
    
    private lazy var sendLinkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send Reset Link", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 27
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.addTarget(self, action: #selector(sendResetLinkTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var backToLoginPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "Remember your password?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var backToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backToLoginTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - BaseController
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(heroContainer)
        heroContainer.addSubview(heroImageView)
        
        contentView.addSubview(bottomContainer)
        
        bottomContainer.addSubview(handleView)
        bottomContainer.addSubview(titleLabel)
        bottomContainer.addSubview(subtitleLabel)
        bottomContainer.addSubview(emailLabel)
        bottomContainer.addSubview(emailTextField)
        bottomContainer.addSubview(statusView)
        bottomContainer.addSubview(sendLinkButton)
        bottomContainer.addSubview(backToLoginPromptLabel)
        bottomContainer.addSubview(backToLoginButton)
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            heroContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroContainer.heightAnchor.constraint(equalToConstant: heroHeight),
            
            heroImageView.topAnchor.constraint(equalTo: heroContainer.topAnchor, constant: -80),
            heroImageView.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: 80),
            
            bottomContainer.topAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: -90),
            bottomContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            handleView.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 42),
            handleView.heightAnchor.constraint(equalToConstant: 4),
            
            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -28),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            emailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            statusView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            statusView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            sendLinkButton.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 12),
            sendLinkButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            sendLinkButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            backToLoginPromptLabel.topAnchor.constraint(equalTo: sendLinkButton.bottomAnchor, constant: 24),
            backToLoginPromptLabel.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor, constant: -24),
            
            backToLoginButton.centerYAnchor.constraint(equalTo: backToLoginPromptLabel.centerYAnchor),
            backToLoginButton.leadingAnchor.constraint(equalTo: backToLoginPromptLabel.trailingAnchor, constant: 6),
            backToLoginButton.trailingAnchor.constraint(lessThanOrEqualTo: titleLabel.trailingAnchor),
            backToLoginButton.bottomAnchor.constraint(equalTo: bottomContainer.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            
            if let message, !message.isEmpty {
                self.statusView.show(message: message, style: .error)
            } else {
                self.statusView.hide()
            }
        }
        
        viewModel.onSuccess = { [weak self] message in
            guard let self else { return }
            
            if let message, !message.isEmpty {
                self.statusView.show(message: message, style: .success)
            } else {
                self.statusView.hide()
            }
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            self.sendLinkButton.isEnabled = !isLoading
            self.sendLinkButton.alpha = isLoading ? 0.7 : 1.0
        }
    }
    
    // MARK: - Actions
    
    @objc private func sendResetLinkTapped() {
        viewModel.sendResetLink(email: emailTextField.text)
    }
    
    @objc private func backToLoginTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func clearStatus() {
        viewModel.clearMessages()
        statusView.hide()
    }
}

// MARK: - UIScrollViewDelegate

extension ForgotPasswordController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        
        if offset > 0 {
            let translateY = -min(offset * 0.22, maxImageTranslate)
            heroImageView.transform = CGAffineTransform(translationX: 0, y: translateY)
        } else {
            heroImageView.transform = .identity
        }
    }
}
