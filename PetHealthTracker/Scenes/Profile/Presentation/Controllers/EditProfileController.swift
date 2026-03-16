//
//  EditProfileController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import UIKit

final class EditProfileController: BaseController {
    
    private let currentUser: UserResponse
    private let viewModel: EditProfileViewModelProtocol
    var onProfileUpdated: ((UserResponse) -> Void)?

    init(
        currentUser: UserResponse,
        viewModel: EditProfileViewModelProtocol = DIContainer.shared.makeEditProfileViewModel()
    ) {
        self.currentUser = currentUser
        self.viewModel = viewModel
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
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
            self.saveButton.isEnabled = !isLoading
            self.saveButton.alpha = isLoading ? 0.7 : 1.0
        }
        
        viewModel.onProfileUpdated = { [weak self] updatedUser in
            guard let self else { return }
            
            self.onProfileUpdated?(updatedUser)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc private func saveTapped() {
        viewModel.saveProfile(name: nameTextField.text)
    }
    
    @objc private func clearStatus() {
        viewModel.clearMessages()
    }
}
