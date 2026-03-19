//
//  ReminderItemCardView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class ReminderItemCardView: UIView {
    
    var onToggleCompleted: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let checkBoxButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.systemGray4.cgColor
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let metaLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let iconWrapView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 18
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let categoryIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        
        containerView.addSubview(checkBoxButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(metaLabel)
        containerView.addSubview(iconWrapView)
        iconWrapView.addSubview(categoryIconView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 84),
            
            checkBoxButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            checkBoxButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            checkBoxButton.widthAnchor.constraint(equalToConstant: 24),
            checkBoxButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: checkBoxButton.trailingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: iconWrapView.leadingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            
            metaLabel.centerYAnchor.constraint(equalTo: subtitleLabel.centerYAnchor),
            metaLabel.leadingAnchor.constraint(equalTo: subtitleLabel.trailingAnchor, constant: 6),
            metaLabel.trailingAnchor.constraint(equalTo: iconWrapView.leadingAnchor, constant: -12),
            
            iconWrapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            iconWrapView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconWrapView.widthAnchor.constraint(equalToConstant: 36),
            iconWrapView.heightAnchor.constraint(equalToConstant: 36),
            
            categoryIconView.centerXAnchor.constraint(equalTo: iconWrapView.centerXAnchor),
            categoryIconView.centerYAnchor.constraint(equalTo: iconWrapView.centerYAnchor),
            categoryIconView.widthAnchor.constraint(equalToConstant: 18),
            categoryIconView.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    private func bindActions() {
        checkBoxButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        containerView.addGestureRecognizer(longPress)
    }
    
    func configure(with item: ReminderItemViewData) {
        titleLabel.text = item.title
        metaLabel.text = "• \(item.petName) • \(metaText(for: item.category))"
        
        switch item.status {
        case .overdue:
            subtitleLabel.text = item.subtitle
            subtitleLabel.textColor = .systemRed
        case .upcoming:
            subtitleLabel.text = item.subtitle
            subtitleLabel.textColor = .mainBlue
        case .completed:
            subtitleLabel.text = item.subtitle
            subtitleLabel.textColor = .onboardingGray
        }
        
        if item.isCompleted {
            checkBoxButton.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.12)
            checkBoxButton.layer.borderColor = UIColor.mainBlue.cgColor
            checkBoxButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkBoxButton.tintColor = .mainBlue
            titleLabel.textColor = .onboardingGray
        } else {
            checkBoxButton.backgroundColor = .clear
            checkBoxButton.layer.borderColor = UIColor.systemGray4.cgColor
            checkBoxButton.setImage(nil, for: .normal)
            titleLabel.textColor = .onboardingBlack
        }
        
        applyCategoryStyle(item.category)
    }
    
    private func metaText(for category: ReminderCategory) -> String {
        switch category {
        case .health: return "Health"
        case .shopping: return "Shopping"
        case .hygiene: return "Hygiene"
        case .general: return "General"
        }
    }
    
    private func applyCategoryStyle(_ category: ReminderCategory) {
        switch category {
        case .health:
            iconWrapView.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
            categoryIconView.image = UIImage(systemName: "cross.case.fill")
            categoryIconView.tintColor = .systemRed
        case .shopping:
            iconWrapView.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.12)
            categoryIconView.image = UIImage(systemName: "bag.fill")
            categoryIconView.tintColor = .systemOrange
        case .hygiene:
            iconWrapView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.12)
            categoryIconView.image = UIImage(systemName: "scissors")
            categoryIconView.tintColor = .systemPurple
        case .general:
            iconWrapView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
            categoryIconView.image = UIImage(systemName: "cross.vial.fill")
            categoryIconView.tintColor = .systemGreen
        }
    }
    
    @objc private func toggleTapped() {
        onToggleCompleted?()
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        onDeleteTapped?()
    }
}
