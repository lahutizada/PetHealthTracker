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
    
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Profile"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.10)
        view.layer.cornerRadius = 44
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .mainBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var avatarTitleLabel: UILabel = {
        let label = UILabel()
        label.text = currentUser.name ?? "User"
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var avatarSubtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Update your personal information"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var infoCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Personal Information"
        label.font = .systemFont(ofSize: 18, weight: .bold)
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
        textField.text = currentUser.name ?? ""
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 18
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray5.cgColor
        textField.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var emailContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emailIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "envelope"))
        imageView.tintColor = .onboardingGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emailValueLabel: UILabel = {
        let label = UILabel()
        label.text = currentUser.email
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emailHintLabel: UILabel = {
        let label = UILabel()
        label.text = "Email address cannot be changed"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statusView: StatusMessageView = {
        let view = StatusMessageView()
        return view
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Changes", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAvatar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    // MARK: - Configure
    
    override var keyboardScrollView: UIScrollView? {
        scrollView
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [
            backButton,
            headerLabel,
            avatarContainer,
            avatarTitleLabel,
            avatarSubtitleLabel,
            infoCard,
            statusView,
            saveButton
        ].forEach(contentView.addSubview)
        
        [
            avatarImageView,
            avatarLabel
        ].forEach(avatarContainer.addSubview)
        
        [
            sectionTitleLabel,
            nameLabel,
            nameTextField,
            emailLabel,
            emailContainer,
            emailHintLabel
        ].forEach(infoCard.addSubview)
        
        [
            emailIconView,
            emailValueLabel
        ].forEach(emailContainer.addSubview)
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
            
            headerLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 12),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -20),
            
            avatarContainer.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 28),
            avatarContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 88),
            avatarContainer.heightAnchor.constraint(equalToConstant: 88),
            
            avatarImageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            
            avatarTitleLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 18),
            avatarTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            avatarTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            avatarSubtitleLabel.topAnchor.constraint(equalTo: avatarTitleLabel.bottomAnchor, constant: 6),
            avatarSubtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            avatarSubtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            infoCard.topAnchor.constraint(equalTo: avatarSubtitleLabel.bottomAnchor, constant: 28),
            infoCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            infoCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            sectionTitleLabel.topAnchor.constraint(equalTo: infoCard.topAnchor, constant: 22),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: infoCard.leadingAnchor, constant: 20),
            sectionTitleLabel.trailingAnchor.constraint(equalTo: infoCard.trailingAnchor, constant: -20),
            
            nameLabel.topAnchor.constraint(equalTo: sectionTitleLabel.bottomAnchor, constant: 20),
            nameLabel.leadingAnchor.constraint(equalTo: sectionTitleLabel.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: sectionTitleLabel.trailingAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            nameTextField.leadingAnchor.constraint(equalTo: sectionTitleLabel.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: sectionTitleLabel.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 56),
            
            emailLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: sectionTitleLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: sectionTitleLabel.trailingAnchor),
            
            emailContainer.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailContainer.leadingAnchor.constraint(equalTo: sectionTitleLabel.leadingAnchor),
            emailContainer.trailingAnchor.constraint(equalTo: sectionTitleLabel.trailingAnchor),
            
            emailIconView.topAnchor.constraint(equalTo: emailContainer.topAnchor, constant: 18),
            emailIconView.leadingAnchor.constraint(equalTo: emailContainer.leadingAnchor, constant: 16),
            emailIconView.widthAnchor.constraint(equalToConstant: 18),
            emailIconView.heightAnchor.constraint(equalToConstant: 18),
            
            emailValueLabel.topAnchor.constraint(equalTo: emailContainer.topAnchor, constant: 16),
            emailValueLabel.leadingAnchor.constraint(equalTo: emailIconView.trailingAnchor, constant: 12),
            emailValueLabel.trailingAnchor.constraint(equalTo: emailContainer.trailingAnchor, constant: -16),
            emailValueLabel.bottomAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: -16),
            
            emailHintLabel.topAnchor.constraint(equalTo: emailContainer.bottomAnchor, constant: 10),
            emailHintLabel.leadingAnchor.constraint(equalTo: sectionTitleLabel.leadingAnchor),
            emailHintLabel.trailingAnchor.constraint(equalTo: sectionTitleLabel.trailingAnchor),
            emailHintLabel.bottomAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: -22),
            
            statusView.topAnchor.constraint(equalTo: infoCard.bottomAnchor, constant: 16),
            statusView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            saveButton.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 16),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 58),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
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
            self.saveButton.isEnabled = !isLoading
            self.saveButton.alpha = isLoading ? 0.7 : 1.0
        }
        
        viewModel.onProfileUpdated = { [weak self] updatedUser in
            guard let self else { return }
            
            self.avatarTitleLabel.text = updatedUser.name ?? "User"
            self.avatarLabel.text = self.configureProfileInitials(from: updatedUser.name)
            self.onProfileUpdated?(updatedUser)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.statusView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    private func configureAvatar() {
        if let url = APIClient.shared.makeFullURL(from: currentUser.avatarUrl) {
            avatarContainer.backgroundColor = .white
            avatarImageView.isHidden = false
            avatarLabel.isHidden = true
            avatarImageView.setImage(from: url)
        } else {
            avatarContainer.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.10)
            avatarImageView.isHidden = true
            avatarLabel.isHidden = false
            avatarLabel.text = configureProfileInitials(from: currentUser.name)
        }
    }
    
    private func configureProfileInitials(from name: String?) -> String {
        guard let name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "U"
        }
        
        let parts = name
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        
        return parts.isEmpty ? "U" : parts.joined()
    }
    
    // MARK: - Actions
    
    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func saveTapped() {
        viewModel.saveProfile(name: nameTextField.text)
    }
    
    @objc private func clearStatus() {
        viewModel.clearMessages()
        statusView.hide()
    }
}
