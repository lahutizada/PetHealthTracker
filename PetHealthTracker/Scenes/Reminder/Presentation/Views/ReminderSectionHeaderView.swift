//
//  ReminderSectionHeaderView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class ReminderSectionHeaderView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let badgeLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        addSubview(badgeLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            badgeLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title: String, badgeText: String?, isDanger: Bool) {
        titleLabel.text = title
        
        if let badgeText {
            badgeLabel.isHidden = false
            badgeLabel.text = badgeText
            badgeLabel.textColor = isDanger ? .systemRed : .mainBlue
            badgeLabel.backgroundColor = isDanger
                ? UIColor.systemRed.withAlphaComponent(0.12)
                : UIColor.mainBlue.withAlphaComponent(0.12)
        } else {
            badgeLabel.isHidden = true
        }
    }
}
