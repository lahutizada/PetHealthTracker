//
//  PetCardContentView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class PetCardContentView: UIView {
    
    var onActionTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let petImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "pawprint.fill")
        iv.tintColor = .mainBlue
        iv.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 28
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let imageStatusBadge: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageStatusIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let statusBadgeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        label.layer.cornerRadius = 11
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.mainBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
        return button
    }()
    
    let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = .systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        
        petImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        
        containerView.addSubview(petImageView)
        containerView.addSubview(imageStatusBadge)
        imageStatusBadge.addSubview(imageStatusIcon)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(infoLabel)
        containerView.addSubview(statusBadgeLabel)
        containerView.addSubview(actionButton)
        containerView.addSubview(chevronImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            petImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            petImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            petImageView.widthAnchor.constraint(equalToConstant: 56),
            petImageView.heightAnchor.constraint(equalToConstant: 56),
            
            imageStatusBadge.widthAnchor.constraint(equalToConstant: 32),
            imageStatusBadge.heightAnchor.constraint(equalToConstant: 32),
            imageStatusBadge.trailingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 6),
            imageStatusBadge.bottomAnchor.constraint(equalTo: petImageView.bottomAnchor, constant: 6),
            
            imageStatusIcon.centerXAnchor.constraint(equalTo: imageStatusBadge.centerXAnchor),
            imageStatusIcon.centerYAnchor.constraint(equalTo: imageStatusBadge.centerYAnchor),
            imageStatusIcon.widthAnchor.constraint(equalToConstant: 14),
            imageStatusIcon.heightAnchor.constraint(equalToConstant: 14),
            
            chevronImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -22),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 14),
            
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 26),
            nameLabel.leadingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -10),
            
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            statusBadgeLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 10),
            statusBadgeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -22),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -22),
            actionButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 96),
            actionButton.heightAnchor.constraint(equalToConstant: 36),
            
            statusBadgeLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -18)
        ])
    }
    
    func configure(
        name: String,
        info: String,
        photoURL: String?,
        species: String,
        statusText: String,
        isMain: Bool,
        showChevron: Bool,
        actionTitle: String?
    ) {
        nameLabel.text = name
        infoLabel.text = info
        
        chevronImageView.isHidden = !showChevron
        
        if isMain {
            actionButton.isHidden = false
            actionButton.setTitle("Main Pet", for: .normal)
            actionButton.setTitleColor(.white, for: .normal)
            actionButton.backgroundColor = .mainBlue
            actionButton.isEnabled = false
        } else if let actionTitle {
            actionButton.isHidden = false
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.setTitleColor(.mainBlue, for: .normal)
            actionButton.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
            actionButton.isEnabled = true
        } else {
            actionButton.isHidden = true
            actionButton.setTitle(nil, for: .normal)
            actionButton.isEnabled = false
        }
        
        applyStatusStyle(text: statusText)
        applyImageBadgeStyle(text: statusText)
        configureImage(photoURL: photoURL, species: species)
    }
    
    private func applyStatusStyle(text: String) {
        statusBadgeLabel.text = text
        
        let lowercased = text.lowercased()
        
        if lowercased.contains("up to date") || lowercased.contains("ready") || lowercased.contains("healthy") {
            statusBadgeLabel.textColor = .systemGreen
            statusBadgeLabel.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        } else if lowercased.contains("check") || lowercased.contains("due") || lowercased.contains("attention") {
            statusBadgeLabel.textColor = .systemOrange
            statusBadgeLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
        } else {
            statusBadgeLabel.textColor = .mainBlue
            statusBadgeLabel.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.12)
        }
    }
    
    private func applyImageBadgeStyle(text: String) {
        let lowercased = text.lowercased()
        
        if lowercased.contains("up to date") || lowercased.contains("ready") || lowercased.contains("healthy") {
            imageStatusBadge.backgroundColor = .systemGreen
            imageStatusIcon.image = UIImage(systemName: "checkmark")
        } else if lowercased.contains("check") || lowercased.contains("due") || lowercased.contains("attention") {
            imageStatusBadge.backgroundColor = .systemOrange
            imageStatusIcon.image = UIImage(systemName: "exclamationmark")
        } else {
            imageStatusBadge.backgroundColor = .mainBlue
            imageStatusIcon.image = UIImage(systemName: "pawprint.fill")
        }
    }
    
    private func configureImage(photoURL: String?, species: String) {
        if let url = APIClient.shared.makeFullURL(from: photoURL) {
            petImageView.cancelImageLoad()
            petImageView.tintColor = nil
            petImageView.contentMode = .scaleAspectFill
            petImageView.backgroundColor = .clear
            petImageView.image = nil
            petImageView.setImage(from: url)
        } else {
            petImageView.cancelImageLoad()
            petImageView.image = UIImage(systemName: "pawprint.fill")
            petImageView.tintColor = .mainBlue
            petImageView.contentMode = .scaleAspectFit
            petImageView.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        }
    }
    
    @objc private func actionTapped() {
        onActionTapped?()
    }
}
