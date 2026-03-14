//
//  LoginController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 28.02.26.
//

import UIKit
import AuthenticationServices

final class LoginController: BaseController {

    var onOpenRegister: (() -> Void)?
    var onOpenForgotPassword: (() -> Void)?
    var onLoginSuccess: (() -> Void)?

    private let viewModel: LoginViewModelProtocol

    // MARK: - Constants
    private let heroHeight: CGFloat = 574.59

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
        iv.image = UIImage(named: "loginHero")
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
        label.text = "Welcome"
        label.font = .systemFont(ofSize: 32, weight: .heavy)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign in to continue tracking your pet’s health, growth and vaccinations."
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "email"
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
        textField.placeholder = "password"
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

    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Forgot password?", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openForgotPassword), for: .touchUpInside)
        return button
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 27
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
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
        label.text = "or continue with"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAppleLogin), for: .touchUpInside)
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return button
    }()

    private lazy var googleButton: UIButton = {
        var config = UIButton.Configuration.filled()

        var attributedTitle = AttributedString("Sign in with Google")
        attributedTitle.font = .systemFont(ofSize: 18, weight: .semibold)
        attributedTitle.foregroundColor = .onboardingBlack

        config.attributedTitle = attributedTitle
        config.image = UIImage(named: "googleIcon")
        config.imagePlacement = .leading
        config.imagePadding = 10
        config.baseForegroundColor = .onboardingBlack
        config.baseBackgroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)
        config.background.cornerRadius = 27

        let button = UIButton(configuration: config)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray5.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.addTarget(self, action: #selector(handleGoogleLogin), for: .touchUpInside)
        return button
    }()

    private lazy var signUpPromptLabel: UILabel = {
        let label = UILabel()
        label.text = "Don't have an account?"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var signUpButtonLink: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(openRegister), for: .touchUpInside)
        return button
    }()

    init(viewModel: LoginViewModelProtocol = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.onError = { [weak self] message in
            guard let self else { return }

            if let message, !message.isEmpty {
                self.errorLabel.text = message
                self.errorLabel.isHidden = false
            } else {
                self.errorLabel.text = nil
                self.errorLabel.isHidden = true
            }
        }

        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            self.loginButton.isEnabled = !isLoading
            self.loginButton.alpha = isLoading ? 0.7 : 1.0
        }

        viewModel.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
    }

    // MARK: - Actions

    @objc private func handleGoogleLogin() {
        showError("Google Sign-In coming soon.")
    }

    @objc private func openRegister() {
        onOpenRegister?()
    }

    @objc private func openForgotPassword() {
        onOpenForgotPassword?()
    }

    @objc private func loginTapped() {
        viewModel.login(
            email: emailTextField.text,
            password: passwordTextField.text
        )
    }

    @objc private func clearError() {
        viewModel.clearError()
    }

    @objc private func togglePasswordVisibility() {
        let shouldShowPassword = passwordTextField.isSecureTextEntry

        passwordTextField.isSecureTextEntry = !shouldShowPassword

        let imageName = shouldShowPassword ? "eye.slash" : "eye"
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .regular)
        let image = UIImage(systemName: imageName, withConfiguration: config)

        showPasswordButton.setImage(image, for: .normal)

        if let password = passwordTextField.text, passwordTextField.isFirstResponder {
            passwordTextField.text = ""
            passwordTextField.insertText(password)
        }
    }

    // MARK: - Helpers

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
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
        bottomContainer.addSubview(emailTextField)
        bottomContainer.addSubview(passwordContainer)
        passwordContainer.addSubview(passwordTextField)
        passwordContainer.addSubview(showPasswordButton)
        bottomContainer.addSubview(forgotPasswordButton)
        bottomContainer.addSubview(errorLabel)
        bottomContainer.addSubview(loginButton)
        bottomContainer.addSubview(leftDivider)
        bottomContainer.addSubview(orLabel)
        bottomContainer.addSubview(rightDivider)
        bottomContainer.addSubview(appleButton)
        bottomContainer.addSubview(googleButton)
        bottomContainer.addSubview(signUpPromptLabel)
        bottomContainer.addSubview(signUpButtonLink)
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

            bottomContainer.topAnchor.constraint(equalTo: heroContainer.bottomAnchor, constant: -20),
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

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            emailTextField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            emailTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            passwordContainer.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            passwordContainer.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordContainer.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),

            passwordTextField.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor, constant: 18),
            passwordTextField.trailingAnchor.constraint(equalTo: showPasswordButton.leadingAnchor, constant: -10),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),

            showPasswordButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor, constant: -16),
            showPasswordButton.centerYAnchor.constraint(equalTo: passwordContainer.centerYAnchor),

            forgotPasswordButton.topAnchor.constraint(equalTo: passwordContainer.bottomAnchor, constant: 10),
            forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordContainer.trailingAnchor),

            errorLabel.centerYAnchor.constraint(equalTo: forgotPasswordButton.centerYAnchor),
            errorLabel.leadingAnchor.constraint(equalTo: passwordContainer.leadingAnchor),
            errorLabel.trailingAnchor.constraint(lessThanOrEqualTo: forgotPasswordButton.leadingAnchor, constant: -12),

            loginButton.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 14),
            loginButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),

            orLabel.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 28),
            orLabel.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),

            leftDivider.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            leftDivider.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            leftDivider.trailingAnchor.constraint(equalTo: orLabel.leadingAnchor, constant: -14),
            leftDivider.heightAnchor.constraint(equalToConstant: 1),

            rightDivider.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            rightDivider.leadingAnchor.constraint(equalTo: orLabel.trailingAnchor, constant: 14),
            rightDivider.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            rightDivider.heightAnchor.constraint(equalToConstant: 1),

            appleButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 22),
            appleButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            appleButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),

            googleButton.topAnchor.constraint(equalTo: appleButton.bottomAnchor, constant: 14),
            googleButton.leadingAnchor.constraint(equalTo: appleButton.leadingAnchor),
            googleButton.trailingAnchor.constraint(equalTo: appleButton.trailingAnchor),

            signUpPromptLabel.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 22),
            signUpPromptLabel.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor, constant: -28),

            signUpButtonLink.centerYAnchor.constraint(equalTo: signUpPromptLabel.centerYAnchor),
            signUpButtonLink.leadingAnchor.constraint(equalTo: signUpPromptLabel.trailingAnchor, constant: 6),
            signUpButtonLink.trailingAnchor.constraint(lessThanOrEqualTo: titleLabel.trailingAnchor),
            signUpButtonLink.bottomAnchor.constraint(equalTo: bottomContainer.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
    }

    override func configureViewModel() {}
}

// MARK: - UIScrollViewDelegate

extension LoginController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y

        if offset > 0 {
            let translateY = -min(offset * 0.22, 36)
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

// MARK: - Apple Sign In

extension LoginController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    @objc private func handleAppleLogin() {
        clearError()

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8)
        else {
            showError("Failed to get Apple token")
            return
        }

        let authorizationCode = credential.authorizationCode.flatMap {
            String(data: $0, encoding: .utf8)
        }

        let fullName = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .joined(separator: " ")

        Task {
            do {
                let request = AppleAuthRequest(
                    identityToken: identityToken,
                    authorizationCode: authorizationCode,
                    fullName: fullName.isEmpty ? nil : fullName,
                    email: credential.email
                )

                let body = try JSONEncoder().encode(request)

                let response: AuthResponse = try await APIClient.shared.request(
                    endpoint: "/auth/apple",
                    method: "POST",
                    body: body
                )

                SessionManager.shared.saveTokens(
                    accessToken: response.accessToken,
                    refreshToken: response.refreshToken
                )

                DispatchQueue.main.async {
                    self.onLoginSuccess?()
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError(AuthErrorAdapter.message(from: error))
                }
            }
        }
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        showError("Apple Sign-In coming soon.")
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = view.window {
            return window
        }

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return UIWindow(windowScene: windowScene)
        }

        fatalError("No valid window scene found")
    }
}
