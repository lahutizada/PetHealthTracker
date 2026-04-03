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
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Profile"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Header Card
    
    private let headerCard: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 28
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 14
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.10)
        view.layer.cornerRadius = 56
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isHidden = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .mainBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let editAvatarButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .mainBlue
        button.layer.cornerRadius = 18
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.12
        button.layer.shadowRadius = 8
        button.layer.shadowOffset = CGSize(width: 0, height: 3)
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
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .center
        label.numberOfLines = 0
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
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Manage your account, preferences and support settings"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: Sections
    
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
    
    private let supportTitle = ProfileSectionTitle(text: "ACCOUNT & SUPPORT")
    private let supportCard = ProfileCardView()
    
    private let accountRow = ProfileChevronRow(
        icon: "person.text.rectangle",
        title: "Edit Profile"
    )
    
    private let helpCenterRow = ProfileChevronRow(
        icon: "questionmark.circle",
        title: "Help Center"
    )
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .white
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.withAlphaComponent(0.12).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "Version 1.0.0"
        label.font = .systemFont(ofSize: 13, weight: .medium)
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
    
    override var keyboardScrollView: UIScrollView? {
        scrollView
    }
    
    override func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        
        contentView.addSubview(headerCard)
        headerCard.addSubview(avatarContainer)
        avatarContainer.addSubview(avatarImageView)
        avatarContainer.addSubview(avatarLabel)
        headerCard.addSubview(editAvatarButton)
        headerCard.addSubview(nameLabel)
        headerCard.addSubview(emailLabel)
        headerCard.addSubview(accountBadge)
        headerCard.addSubview(subtitleLabel)
        headerCard.addSubview(loadingView)
        
        contentView.addSubview(preferencesTitle)
        contentView.addSubview(preferencesCard)
        
        preferencesCard.addArrangedSubview(notificationsRow)
        preferencesCard.addArrangedSubview(darkModeRow)
        preferencesCard.addArrangedSubview(unitsRow)
        
        contentView.addSubview(supportTitle)
        contentView.addSubview(supportCard)
        
        supportCard.addArrangedSubview(accountRow)
        supportCard.addArrangedSubview(helpCenterRow)
        
        contentView.addSubview(logoutButton)
        contentView.addSubview(versionLabel)
        
        avatarContainer.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(editAvatarTapped))
        avatarContainer.addGestureRecognizer(tap)
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
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            headerCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            avatarContainer.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 24),
            avatarContainer.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            avatarContainer.widthAnchor.constraint(equalToConstant: 112),
            avatarContainer.heightAnchor.constraint(equalToConstant: 112),
            
            avatarImageView.topAnchor.constraint(equalTo: avatarContainer.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: avatarContainer.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            
            editAvatarButton.trailingAnchor.constraint(equalTo: avatarContainer.trailingAnchor),
            editAvatarButton.bottomAnchor.constraint(equalTo: avatarContainer.bottomAnchor),
            editAvatarButton.widthAnchor.constraint(equalToConstant: 36),
            editAvatarButton.heightAnchor.constraint(equalToConstant: 36),
            
            nameLabel.topAnchor.constraint(equalTo: avatarContainer.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            emailLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 24),
            emailLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -24),
            
            accountBadge.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            accountBadge.centerXAnchor.constraint(equalTo: headerCard.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: accountBadge.bottomAnchor, constant: 12),
            subtitleLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -24),
            subtitleLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -24),
            
            loadingView.centerXAnchor.constraint(equalTo: avatarContainer.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: avatarContainer.centerYAnchor),
            
            preferencesTitle.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 28),
            preferencesTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            preferencesCard.topAnchor.constraint(equalTo: preferencesTitle.bottomAnchor, constant: 10),
            preferencesCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            preferencesCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            supportTitle.topAnchor.constraint(equalTo: preferencesCard.bottomAnchor, constant: 24),
            supportTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            supportCard.topAnchor.constraint(equalTo: supportTitle.bottomAnchor, constant: 10),
            supportCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            supportCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            logoutButton.topAnchor.constraint(equalTo: supportCard.bottomAnchor, constant: 30),
            logoutButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            logoutButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            logoutButton.heightAnchor.constraint(equalToConstant: 56),
            
            versionLabel.topAnchor.constraint(equalTo: logoutButton.bottomAnchor, constant: 14),
            versionLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            versionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -36)
        ])
    }
    
    override func configureViewModel() {
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                self?.loadingView.isHidden = !isLoading
                isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
            }
        }
        
        viewModel.onProfileLoaded = { [weak self] user in
            self?.currentUser = user
            self?.applyProfile(user)
        }
        
        viewModel.onAvatarUploaded = { [weak self] avatarUrl in
            guard let self else { return }
            guard let url = APIClient.shared.makeFullURL(from: avatarUrl) else { return }
            
            self.avatarContainer.backgroundColor = .white
            self.avatarImageView.isHidden = false
            self.avatarLabel.isHidden = true
            self.avatarImageView.tintColor = nil
            self.avatarImageView.setImage(from: url)
            
            if let user = self.currentUser {
                self.currentUser = UserResponse(
                    sub: user.sub,
                    email: user.email,
                    name: user.name,
                    avatarUrl: avatarUrl,
                    highlightedPetId: user.highlightedPetId
                )
            }
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
        
        if let url = APIClient.shared.makeFullURL(from: user.avatarUrl) {
            avatarImageView.cancelImageLoad()
            avatarContainer.backgroundColor = .white
            avatarImageView.isHidden = false
            avatarLabel.isHidden = true
            avatarImageView.tintColor = nil
            avatarImageView.contentMode = .scaleAspectFill
            avatarImageView.setImage(from: url)
        } else {
            avatarImageView.cancelImageLoad()
            avatarContainer.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.10)
            avatarImageView.isHidden = true
            avatarLabel.isHidden = false
            avatarLabel.text = initials(from: user.name ?? user.email)
        }
    }
    
    private func initials(from name: String) -> String {
        let parts = name
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        
        return parts.isEmpty ? "U" : parts.joined()
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
                self.avatarContainer.backgroundColor = .white
                self.avatarImageView.image = image
                self.avatarImageView.tintColor = nil
                self.avatarImageView.isHidden = false
                self.avatarLabel.isHidden = true
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
