//
//  ResetPasswordController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

final class ResetPasswordController: BaseController {
    
    private let token: String
    
    init(token: String) {
        self.token = token
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    override func configureViewModel() {}
    
    @objc private func resetTapped() {
        clearStatus()
        
        guard
            let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            let confirmPassword = confirmPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
            !password.isEmpty,
            !confirmPassword.isEmpty
        else {
            showError("All fields are required")
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
                try await AuthService.shared.resetPassword(
                    token: token,
                    newPassword: password
                )
                
                DispatchQueue.main.async {
                    self.showSuccess("Password has been reset successfully")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError("Invalid or expired reset link")
                }
            }
        }
    }
    
    @objc private func clearStatus() {
        statusLabel.text = nil
        statusLabel.isHidden = true
    }
    
    private func showError(_ message: String) {
        statusLabel.text = message
        statusLabel.textColor = .systemRed
        statusLabel.isHidden = false
    }
    
    private func showSuccess(_ message: String) {
        statusLabel.text = message
        statusLabel.textColor = .systemGreen
        statusLabel.isHidden = false
    }
}

private extension UITextField {
    func setLeftPadding(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: 1))
        leftView = paddingView
        leftViewMode = .always
    }
}
