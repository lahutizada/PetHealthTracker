//
//  ReminderSectionHeaderView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class ReminderSectionHeaderView: UIView {
    
    var onToggleTapped: (() -> Void)?
    
    private(set) var isExpanded: Bool = true
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let badgeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 13, weight: .bold)
        label.textInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        label.layer.cornerRadius = 14
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Hide", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(badgeLabel)
        addSubview(toggleButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            toggleButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            badgeLabel.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -10),
            badgeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: badgeLabel.leadingAnchor, constant: -12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(
        title: String,
        badgeText: String?,
        isDanger: Bool,
        isExpanded: Bool = true
    ) {
        titleLabel.text = title
        self.isExpanded = isExpanded
        
        let hasItems = badgeText != nil && !(badgeText?.isEmpty ?? true)
        
        toggleButton.isHidden = !hasItems
        badgeLabel.isHidden = !hasItems
        
        if hasItems {
            toggleButton.setTitle(isExpanded ? "Hide" : "Show all", for: .normal)
            badgeLabel.text = badgeText
            
            if isDanger {
                badgeLabel.textColor = .systemRed
                badgeLabel.backgroundColor = UIColor.systemRed.withAlphaComponent(0.12)
            } else {
                badgeLabel.textColor = .mainBlue
                badgeLabel.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.12)
            }
        } else {
            badgeLabel.text = nil
        }
    }
    
    @objc private func toggleTapped() {
        isExpanded.toggle()
        toggleButton.setTitle(isExpanded ? "Hide" : "Show all", for: .normal)
        onToggleTapped?()
    }
}
