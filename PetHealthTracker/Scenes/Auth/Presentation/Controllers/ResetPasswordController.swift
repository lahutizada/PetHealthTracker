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
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "new password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 27
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.setLeftPadding(18)
        textField.addTarget(self, action: #selector(clearStatus), for: .editingChanged)
        return textField
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "confirm new password"
        textField.borderStyle = .none
        textField.isSecureTextEntry = true
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 27
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.setLeftPadding(18)
        textField.addTarget(self, action: #selector(clearStatus), for: .editingChanged)
        return textField
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset Password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 19, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 27
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        return button
    }()
    
    override func configureUI() {
        view.backgroundColor = .white
        title = "Reset Password"
        
        view.addSubview(passwordTextField)
        view.addSubview(confirmPasswordTextField)
        view.addSubview(statusLabel)
        view.addSubview(resetButton)
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 16),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 16),
            statusLabel.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            
            resetButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            resetButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onError = { [weak self] message in
            guard let self else { return }
            
            if let message, !message.isEmpty {
                self.statusLabel.text = message
                self.statusLabel.textColor = .systemRed
                self.statusLabel.isHidden = false
            } else if self.statusLabel.textColor == .systemRed {
                self.statusLabel.text = nil
                self.statusLabel.isHidden = true
            }
        }
        
        viewModel.onSuccess = { [weak self] message in
            guard let self else { return }
            
            if let message, !message.isEmpty {
                self.statusLabel.text = message
                self.statusLabel.textColor = .systemGreen
                self.statusLabel.isHidden = false
            } else if self.statusLabel.textColor == .systemGreen {
                self.statusLabel.text = nil
                self.statusLabel.isHidden = true
            }
        }
        
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            self.resetButton.isEnabled = !isLoading
            self.resetButton.alpha = isLoading ? 0.7 : 1.0
        }
        
        viewModel.onResetSuccess = { [weak self] in
            guard let self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                self.navigationController?.popToRootViewController(animated: true)
            }
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
    }
}
