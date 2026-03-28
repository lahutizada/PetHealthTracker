//
//  ResetPasswordController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

final class ResetPasswordController: BaseController {
    
    private let token: String
    private let viewModel: ResetPasswordViewModelProtocol
    
    init(
        token: String,
        viewModel: ResetPasswordViewModelProtocol = DIContainer.shared.makeResetPasswordViewModel()
    ) {
        self.token = token
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.keyboardDismissMode = .interactive
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = AppBackButton()
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var heroIconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.10)
        view.layer.cornerRadius = 38
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var heroIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "lock.rotation"))
        imageView.tintColor = .mainBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Reset Password"
        label.font = .systemFont(ofSize: 30, weight: .bold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Create a new password for your account. Make sure it’s secure and easy to remember."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var formCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowRadius = 14
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "New Password"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmPasswordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Password"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var passwordContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter new password"
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .clear
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(clearStatus), for: .editingChanged)
        return textField
    }()
    
    private lazy var showPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
        button.setImage(UIImage(systemName: "eye"), for: .normal)
        button.tintColor = .onboardingGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.widthAnchor.constraint(equalToConstant: 24).isActive = true
        button.heightAnchor.constraint(equalToConstant: 24).isActive = true
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return button
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm new password"
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 18
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPadding(18)
        textField.addTarget(self, action: #selector(clearStatus), for: .editingChanged)
        return textField
    }()
    
    private lazy var statusView: StatusMessageView = {
        let view = StatusMessageView()
        return view
    }()
    
    private lazy var hintLabel: UILabel = {
        let label = UILabel()
        label.text = "Your password must be at least 8 characters."
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save New Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - BaseController
    
    override var keyboardScrollView: UIScrollView? {
        scrollView
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            backButton,
            heroIconContainer,
            titleLabel,
            subtitleLabel,
            formCard
        ].forEach(contentView.addSubview)
        
        heroIconContainer.addSubview(heroIconView)
        
        [
            passwordTitleLabel,
            passwordContainer,
            confirmPasswordTitleLabel,
            confirmPasswordTextField,
            statusView,
            hintLabel,
            resetButton
        ].forEach(formCard.addSubview)
        
        passwordContainer.addSubview(passwordTextField)
        passwordContainer.addSubview(showPasswordButton)
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            backButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            heroIconContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 28),
            heroIconContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            heroIconContainer.widthAnchor.constraint(equalToConstant: 76),
            heroIconContainer.heightAnchor.constraint(equalToConstant: 76),
            
            heroIconView.centerXAnchor.constraint(equalTo: heroIconContainer.centerXAnchor),
            heroIconView.centerYAnchor.constraint(equalTo: heroIconContainer.centerYAnchor),
            heroIconView.widthAnchor.constraint(equalToConstant: 34),
            heroIconView.heightAnchor.constraint(equalToConstant: 34),
            
            titleLabel.topAnchor.constraint(equalTo: heroIconContainer.bottomAnchor, constant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            
            formCard.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            formCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            formCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            formCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),
            
            passwordTitleLabel.topAnchor.constraint(equalTo: formCard.topAnchor, constant: 24),
            passwordTitleLabel.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            passwordTitleLabel.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            
            passwordContainer.topAnchor.constraint(equalTo: passwordTitleLabel.bottomAnchor, constant: 10),
            passwordContainer.leadingAnchor.constraint(equalTo: formCard.leadingAnchor, constant: 20),
            passwordContainer.trailingAnchor.constraint(equalTo: formCard.trailingAnchor, constant: -20),
            passwordContainer.heightAnchor.constraint(equalToConstant: 56),
            
            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor, constant: 18),
            passwordTextField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -10),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -16),
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            
            confirmPasswordTitleLabel.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 20),
            confirmPasswordTitleLabel.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            confirmPasswordTitleLabel.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordTitleLabel.bottomAnchor, constant: 10),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 56),
            
            statusView.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 18),
            statusView.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            statusView.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
            
            hintLabel.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 14),
            hintLabel.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
            
            resetButton.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 22),
            resetButton.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 58),
            resetButton.bottomAnchor.constraint(equalTo: formCard.bottomAnchor, constant: -24)
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
            self.resetButton.isEnabled = !isLoading
            self.resetButton.alpha = isLoading ? 0.7 : 1.0
        }
        
        viewModel.onResetSuccess = {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? SceneDelegate {
                    sceneDelegate.appCoordinator?.showLogin()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func resetTapped() {
        viewModel.resetPassword(
            token: token,
            password: passwordTextField.text,
            confirmPassword: confirmPasswordTextField.text
        )
    }
    
    @objc private func clearStatus() {
        viewModel.clearMessages()
        statusView.hide()
    }
    
    @objc private func togglePasswordVisibility() {
        let shouldShowPassword = passwordTextField.isSecureTextEntry
        
        passwordTextField.isSecureTextEntry = !shouldShowPassword
        confirmPasswordTextField.isSecureTextEntry = !shouldShowPassword
        
        let imageName = shouldShowPassword ? "eye.slash" : "eye"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        
        showPasswordButton.setImage(image, for: .normal)
        
        if let password = passwordTextField.text, passwordTextField.isFirstResponder {
            passwordTextField.text = ""
            passwordTextField.insertText(password)
        }
        
        if let confirmPassword = confirmPasswordTextField.text, confirmPasswordTextField.isFirstResponder {
            confirmPasswordTextField.text = ""
            confirmPasswordTextField.insertText(confirmPassword)
        }
    }
}
