//
//  RecordPetHeaderView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import UIKit

final class RecordPetHeaderView: UIView {
    
    enum Style {
        case regular
        case compact
    }
    
    var onChangePetTapped: (() -> Void)?
    
    private let style: Style
    private var changeButtonWidthConstraint: NSLayoutConstraint!
    
    init(style: Style = .regular) {
        self.style = style
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - UI
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = style == .regular ? 24 : 18
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.035
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        imageView.layer.cornerRadius = style == .regular ? 28 : 22
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: style == .regular ? 18 : 16, weight: .bold)
        label.textColor = .onboardingBlack
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var breedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: style == .regular ? 14 : 13, weight: .medium)
        label.textColor = .onboardingGray
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: style == .regular ? 14 : 13, weight: .medium)
        label.textColor = .onboardingGray
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: style == .regular ? 14 : 13, weight: .medium)
        label.textColor = .onboardingGray
        label.lineBreakMode = .byTruncatingTail
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var textStack: UIStackView = {
        let arranged: [UIView] = style == .regular ? [nameLabel, metaLabel] : [nameLabel, breedLabel, ageLabel]
        let stack = UIStackView(arrangedSubviews: arranged)
        stack.axis = .vertical
        stack.spacing = style == .regular ? 5 : 3
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var changePetButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = style == .regular ? "Change" : "Select"
        config.baseBackgroundColor = UIColor.mainBlue.withAlphaComponent(style == .regular ? 0.12 : 0.08)
        config.baseForegroundColor = .mainBlue
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(
            top: style == .regular ? 10 : 8,
            leading: style == .regular ? 16 : 14,
            bottom: style == .regular ? 10 : 8,
            trailing: style == .regular ? 16 : 14
        )
        
        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: style == .regular ? 15 : 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(changePetTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        containerView.addSubview(petImageView)
        containerView.addSubview(textStack)
        containerView.addSubview(changePetButton)
    }
    
    private func setupConstraints() {
        changeButtonWidthConstraint = changePetButton.widthAnchor.constraint(
            equalToConstant: style == .regular ? 92 : 78
        )
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerView.heightAnchor.constraint(equalToConstant: style == .regular ? 98 : 78),
            
            petImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 14),
            petImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            petImageView.widthAnchor.constraint(equalToConstant: style == .regular ? 56 : 44),
            petImageView.heightAnchor.constraint(equalToConstant: style == .regular ? 56 : 44),
            
            changePetButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -14),
            changePetButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            changePetButton.heightAnchor.constraint(equalToConstant: style == .regular ? 38 : 32),
            changeButtonWidthConstraint,
            
            textStack.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textStack.leadingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 14),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: changePetButton.leadingAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configure
    
    func configure(with item: PetPickerItemViewData) {
        nameLabel.text = item.name
        breedLabel.text = item.breed
        ageLabel.text = item.ageText
        
        if style == .regular {
            metaLabel.text = "\(item.breed) • \(formattedAge(item.ageText))"
        }
        
        if let url = APIClient.shared.makeFullURL(from: item.photoURL) {
            petImageView.cancelImageLoad()
            petImageView.setImage(from: url)
            petImageView.contentMode = .scaleAspectFill
        } else {
            petImageView.cancelImageLoad()
            petImageView.image = UIImage(systemName: "pawprint.fill")
            petImageView.tintColor = .mainBlue
            petImageView.contentMode = .scaleAspectFit
        }
        
        var config = changePetButton.configuration
        config?.title = item.isSelected ? "Change" : (style == .compact ? "Select" : "Change")
        changePetButton.configuration = config
        
        changeButtonWidthConstraint.constant = style == .regular ? 92 : 78
    }
    
    private func formattedAge(_ value: String) -> String {
        value
            .replacingOccurrences(of: "y", with: " Years")
            .replacingOccurrences(of: "m", with: " Months")
            .replacingOccurrences(of: " 0 Months", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Actions
    
    @objc private func changePetTapped() {
        onChangePetTapped?()
    }
}
