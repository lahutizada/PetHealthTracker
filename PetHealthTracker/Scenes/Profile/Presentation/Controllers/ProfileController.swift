//
//  ProfileController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit
import PhotosUI

final class ProfileController: BaseController, PHPickerViewControllerDelegate {
    
    var onEditProfileTapped: ((UserResponse, @escaping (UserResponse) -> Void) -> Void)?
    
    private let viewModel: ProfileViewModelProtocol
    private var currentUser: UserResponse?

    init(viewModel: ProfileViewModelProtocol = DIContainer.shared.makeProfileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.crop.circle.fill")
        iv.tintColor = .mainBlue
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        iv.layer.cornerRadius = 60
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let editAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pencil"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading..."
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .onboardingBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let accountBadge: UILabel = {
        let label = UILabel()
        label.text = "  ACCOUNT  "
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.12)
        label.textColor = .mainBlue
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let preferencesTitle = ProfileSectionTitle(text: "PREFERENCES")
    private let preferencesCard = ProfileCardView()
    
    private let notificationsRow = ProfileSwitchRow(
        icon: "bell.fill",
        title: "Notifications"
    )
    
    private let darkModeRow = ProfileSwitchRow(
        icon: "moon.fill",
        title: "Dark Mode"
    )
    
    private let unitsRow = ProfileChevronRow(
        icon: "scalemass.fill",
        title: "Units",
        value: "kg, cm"
    )
    
    private let supportTitle = ProfileSectionTitle(text: "SUPPORT")
    private let supportCard = ProfileCardView()
    
    private let helpCenterRow = ProfileChevronRow(
        icon: "questionmark.circle",
        title: "Help Center"
    )
    
    private let accountRow = ProfileChevronRow(
        icon: "person.text.rectangle",
        title: "Edit Profile"
    )
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Version 1.0.0"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = true
        return view
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        editAvatarButton.addTarget(self, action: #selector(editAvatarTapped), for: .touchUpInside)
        
        accountRow.onTap = { [weak self] in
            self?.openEditProfile()
        }
        
        helpCenterRow.onTap = {
            print("Help Center tapped")
        }
        
        unitsRow.onTap = {
            print("Units tapped")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        viewModel.loadProfile()
    }
    
    // MARK: - BaseController
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(editAvatarButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(emailLabel)
        contentView.addSubview(accountBadge)
        
        contentView.addSubview(preferencesTitle)
        contentView.addSubview(preferencesCard)
        
        preferencesCard.addArrangedSubview(notificationsRow)
        preferencesCard.addArrangedSubview(darkModeRow)
        preferencesCard.addArrangedSubview(unitsRow)
        
        contentView.addSubview(supportTitle)
        contentView.addSubview(supportCard)
        
        supportCard.addArrangedSubview(helpCenterRow)
        supportCard.addArrangedSubview(accountRow)
        
        contentView.addSubview(logoutButton)
        contentView.addSubview(versionLabel)
        contentView.addSubview(loadingView)
        
        avatarImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(editAvatarTapped))
        avatarImageView.addGestureRecognizer(tap)
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
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            avatarImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 120),
            avatarImageView.heightAnchor.constraint(equalToConstant: 120),
            
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarImageView.trailingAnchor),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor),
            editAvatarButton.widthAnchor.constraint(equalToConstant: 32),
            editAvatarButton.heightAnchor.constraint(equalToConstant: 32),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            
            accountBadge.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            accountBadge.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            preferencesTitle.topAnchor.constraint(equalTo: accountBadge.bottomAnchor, constant: 30),
            preferencesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            preferencesCard.topAnchor.constraint(equalTo: preferencesTitle.bottomAnchor, constant: 10),
            preferencesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            preferencesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            supportTitle.topAnchor.constraint(equalTo: preferencesCard.bottomAnchor, constant: 24),
            supportTitle.leadingAnchor.constraint(equalTo: preferencesTitle.leadingAnchor),
            
            supportCard.topAnchor.constraint(equalTo: supportTitle.bottomAnchor, constant: 10),
            supportCard.leadingAnchor.constraint(equalTo: preferencesCard.leadingAnchor),
            supportCard.trailingAnchor.constraint(equalTo: preferencesCard.trailingAnchor),
            
            logoutButton.topAnchor.constraint(equalTo: supportCard.bottomAnchor, constant: 30),
            logoutButton.leadingAnchor.constraint(equalTo: preferencesCard.leadingAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: preferencesCard.trailingAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: 56),
            
            versionLabel.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 12),
            versionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -36),
            
            loadingView.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            guard let self else { return }
            isLoading ? self.loadingView.startAnimating() : self.loadingView.stopAnimating()
        }
        
        viewModel.onProfileLoaded = { [weak self] user in
            self?.currentUser = user
            self?.applyProfile(user)
        }
        
        viewModel.onAvatarUploaded = { [weak self] avatarUrl in
            guard let self, let url = URL(string: avatarUrl) else { return }
            self.avatarImageView.tintColor = nil
            self.avatarImageView.setImage(from: url)
        }
        
        viewModel.onLogoutSuccess = { [weak self] in
            guard
                let self,
                let windowScene = self.view.window?.windowScene,
                let sceneDelegate = windowScene.delegate as? SceneDelegate
            else { return }
            
            sceneDelegate.appCoordinator?.logout()
        }
        
        viewModel.onError = { error in
            print("Profile error:", error)
        }
    }
    
    // MARK: - Helpers
    
    private func applyProfile(_ user: UserResponse) {
        let cleanedName = user.name?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let cleanedName, !cleanedName.isEmpty {
            nameLabel.text = cleanedName
        } else {
            let fallbackName = user.email.components(separatedBy: "@").first ?? "User"
            nameLabel.text = fallbackName.capitalized
        }

        emailLabel.text = user.email

        if let avatarUrl = user.avatarUrl,
           let url = URL(string: avatarUrl) {
            avatarImageView.tintColor = nil
            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.setImage(from: url)
        } else {
            avatarImageView.cancelImageLoad()
            avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
            avatarImageView.tintColor = .mainBlue
        }
    }
    
    // MARK: - Avatar
    
    @objc private func editAvatarTapped() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            guard let self, let image = image as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.avatarImageView.image = image
                self.avatarImageView.tintColor = nil
            }
            
            self.viewModel.uploadAvatar(image)
        }
    }
    
    // MARK: - Navigation
    
    private func openEditProfile() {
        guard let currentUser else { return }

        onEditProfileTapped?(currentUser) { [weak self] updatedUser in
            self?.currentUser = updatedUser
            self?.applyProfile(updatedUser)
        }
    }
    
    // MARK: - Logout
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.viewModel.logout()
        })
        
        present(alert, animated: true)
    }
}
