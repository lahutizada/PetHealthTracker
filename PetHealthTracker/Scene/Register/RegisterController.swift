//
//  RegisterController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 07.03.26.
//

import UIKit
import AuthenticationServices

final class RegisterController: BaseController {
    
    // MARK: - Constants
    private let heroHeight: CGFloat = 599.84
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
        iv.image = UIImage(named: "registerHero")
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
        label.text = "Create Account"
        label.font = .systemFont(ofSize: 30, weight: .heavy)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Start tracking your pet’s health today"
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
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
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm Password"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var fullNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "enter your full name"
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 27
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.setLeftPadding(18)
        textField.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return textField
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
        textField.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "enter password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return textField
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "confirm password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.addTarget(self, action: #selector(clearError), for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 27
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return view
    }()
    
    private lazy var confirmPasswordContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 27
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return view
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
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 19, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 27
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.addTarget(self, action: #selector(createAccountTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var leftDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var rightDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var orLabel: UILabel = {
        let label = UILabel()
        label.text = "OR SIGN UP WITH"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var googleButton: UIButton = {
        var config = UIButton.Configuration.filled()
        
        var attributedTitle = AttributedString("Google")
        attributedTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        attributedTitle.foregroundColor = .onboardingBlack
        
        config.attributedTitle = attributedTitle
        config.image = UIImage(named: "googleIcon")
        config.imagePlacement = .leading
        config.imagePadding = 8
        config.baseForegroundColor = .onboardingBlack
        config.baseBackgroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        config.background.cornerRadius = 27
        
        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "Already have an account?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var loginButtonLink: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(backToLogin), for: .touchUpInside)
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
        
        bottomContainer.addSubview(fullNameLabel)
        bottomContainer.addSubview(fullNameTextField)
        
        bottomContainer.addSubview(emailLabel)
        bottomContainer.addSubview(emailTextField)
        
        bottomContainer.addSubview(passwordLabel)
        bottomContainer.addSubview(passwordContainer)
        passwordContainer.addSubview(passwordTextField)
        passwordContainer.addSubview(showPasswordButton)
        
        bottomContainer.addSubview(confirmPasswordLabel)
        bottomContainer.addSubview(confirmPasswordContainer)
        confirmPasswordContainer.addSubview(confirmPasswordTextField)
        
        bottomContainer.addSubview(errorLabel)
        bottomContainer.addSubview(createAccountButton)
        
        bottomContainer.addSubview(leftDivider)
        bottomContainer.addSubview(orLabel)
        bottomContainer.addSubview(rightDivider)
        
        bottomContainer.addSubview(googleButton)
        bottomContainer.addSubview(appleButton)
        
        bottomContainer.addSubview(loginPromptLabel)
        bottomContainer.addSubview(loginButtonLink)
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            // Scroll
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            // Hero
            heroContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            heroContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            heroContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            heroContainer.heightAnchor.constraint(equalToConstant: heroHeight),
            
            heroImageView.topAnchor.constraint(equalTo: heroContainer.topAnchor, constant: -80),
            heroImageView.leadingAnchor.constraint(equalTo: heroContainer.leadingAnchor),
            heroImageView.trailingAnchor.constraint(equalTo: heroContainer.trailingAnchor),
            heroImageView.bottomAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: 80),
            
            // Bottom card
            bottomContainer.topAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: -30),
            bottomContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Handle
            handleView.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 42),
            handleView.heightAnchor.constraint(equalToConstant: 4),
            
            // Header
            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -28),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Full name
            fullNameLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            fullNameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            fullNameLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            fullNameTextField.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 12),
            fullNameTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            fullNameTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Email
            emailLabel.topAnchor.constraint(equalTo: fullNameTextField.bottomAnchor, constant: 22),
            emailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Password
            passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 22),
            passwordLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            passwordLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            passwordContainer.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 12),
            passwordContainer.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            passwordContainer.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor, constant: 18),
            passwordTextField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -10),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            
            showPasswordButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -16),
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),
            
            // Confirm password
            confirmPasswordLabel.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 22),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            confirmPasswordLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            confirmPasswordContainer.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 12),
            confirmPasswordContainer.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            confirmPasswordContainer.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordContainer.leadingAnchor, constant: 18),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: confirmPasswordContainer.trailingAnchor, constant: -18),
            confirmPasswordTextField.centerYAnchor.constraint(equalTo: confirmPasswordContainer.centerYAnchor),
            
            // Error
            errorLabel.topAnchor.constraint(equalTo: confirmPasswordContainer.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Create account
            createAccountButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 12),
            createAccountButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            createAccountButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Divider
            orLabel.topAnchor.constraint(equalTo: createAccountButton.bottomAnchor, constant: 28),
            orLabel.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            
            leftDivider.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            leftDivider.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            leftDivider.trailingAnchor.constraint(equalTo: orLabel.leadingAnchor, constant: -14),
            leftDivider.heightAnchor.constraint(equalToConstant: 1),
            
            rightDivider.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            rightDivider.leadingAnchor.constraint(equalTo: orLabel.trailingAnchor, constant: 14),
            rightDivider.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            rightDivider.heightAnchor.constraint(equalToConstant: 1),
            
            // Social
            googleButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 24),
            googleButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            googleButton.trailingAnchor.constraint(equalTo: bottomContainer.centerXAnchor, constant: -8),
            
            appleButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 24),
            appleButton.leadingAnchor.constraint(equalTo: bottomContainer.centerXAnchor, constant: 8),
            appleButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            // Bottom login
            loginPromptLabel.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 28),
            loginPromptLabel.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor, constant: -34),
            
            loginButtonLink.centerYAnchor.constraint(equalTo: loginPromptLabel.centerYAnchor),
            loginButtonLink.leadingAnchor.constraint(equalTo: loginPromptLabel.trailingAnchor, constant: 6),
            loginButtonLink.trailingAnchor.constraint(lessThanOrEqualTo: titleLabel.trailingAnchor),
            loginButtonLink.bottomAnchor.constraint(equalTo: bottomContainer.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }
    
    override func configureViewModel() {}
    
    // MARK: - Actions
    
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
    
    @objc private func handleAppleLogin() {
        showError("Apple Sign-In coming soon.")
    }
    
    @objc private func handleGoogleLogin() {
        showError("Google Sign-In coming soon.")
    }
    
    @objc private func backToLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func clearError() {
        errorLabel.text = nil
        errorLabel.isHidden = true
    }
    
    @objc private func createAccountTapped() {
        clearError()
        
        guard
            let name = fullNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !name.isEmpty,
            !email.isEmpty,
            !password.isEmpty,
            !confirmPassword.isEmpty
        else {
            showError("All fields are required")
            return
        }
        
        guard email.contains("@"), email.contains(".") else {
            showError("Incorrect email format")
            return
        }
        
        guard password.count >= 8 else {
            showError("Password must be at least 8 characters")
            return
        }
        
        guard password == confirmPassword else {
            showError("Passwords do not match")
            return
        }
        
        Task {
            do {
                let response = try await AuthService.shared.register(
                    name: name,
                    email: email,
                    password: password
                )
                
                SessionManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )
                
                DispatchQueue.main.async {
                    self.goToMainApp()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError(self.userFriendlyError(error))
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    
    private func goToMainApp() {
        guard
            let windowScene = view.window?.windowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate
        else { return }
        
        sceneDelegate.window?.rootViewController = MainTabBarController()
        sceneDelegate.window?.makeKeyAndVisible()
    }
    
    private func userFriendlyError(_ error: Error) -> String {
        let message = (error as NSError).localizedDescription.lowercased()
        
        if message.contains("email already in use") {
            return "This email is already in use"
        }
        
        if message.contains("email must be an email") {
            return "Incorrect email format"
        }
        
        if message.contains("email should not be empty") {
            return "Email is required"
        }
        
        if message.contains("password should not be empty") {
            return "Password is required"
        }
        
        if message.contains("password must be longer") || message.contains("password must be at least 8") {
            return "Password must be at least 8 characters"
        }
        
        if message.contains("name should not be empty") || message.contains("fullname should not be empty") {
            return "Full name is required"
        }
        
        if message.contains("could not connect to the server") {
            return "Cannot connect to server"
        }
        
        return "Something went wrong. Please try again."
    }
}

// MARK: - UIScrollViewDelegate

extension RegisterController: UIScrollViewDelegate {
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

// MARK: - UITextField Padding

private extension UITextField {
    func setLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }
}
