//
//  EditProfileController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import UIKit

final class EditProfileController: BaseController {
    
    private let currentUser: UserResponse
    var onProfileUpdated: ((UserResponse) -> Void)?
    
    init(currentUser: UserResponse) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Profile"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Full Name"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter your full name"
        textField.text = currentUser.name
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 18, weight: .regular)
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 27
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 56).isActive = true
        textField.setLeftPadding(18)
        textField.addTarget(self, action: #selector(clearStatus), for: .editingChanged)
        return textField
    }()
    
    private lazy var emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailValueLabel: UILabel = {
        let label = UILabel()
        label.text = currentUser.email
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 19, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 27
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 56).isActive = true
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        view.addSubview(titleLabel)
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(emailLabel)
        view.addSubview(emailValueLabel)
        view.addSubview(statusLabel)
        view.addSubview(saveButton)
    }
    
    override func configureConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            nameLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28),
            nameLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 12),
            nameTextField.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            emailLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            emailValueLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailValueLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            emailValueLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            statusLabel.topAnchor.constraint(equalTo: emailValueLabel.bottomAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            saveButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    override func configureViewModel() {}
    
    @objc private func saveTapped() {
        clearStatus()
        
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            showError("Full name is required")
            return
        }
        
        guard name.count >= 2 else {
            showError("Name must be at least 2 characters")
            return
        }
        
        Task {
            do {
                let updatedUser = try await UsersService.shared.updateProfile(name: name)
                
                DispatchQueue.main.async {
                    self.showSuccess("Profile updated")
                    self.onProfileUpdated?(updatedUser)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showError("Failed to update profile")
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
