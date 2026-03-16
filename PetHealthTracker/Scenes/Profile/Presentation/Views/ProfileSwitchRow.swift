//
//  ProfileSwitchRow.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit

final class ProfileSwitchRow: UIView {

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    let toggle = UISwitch()

    init(icon: String, title: String) {
        super.init(frame: .zero)

        iconView.image = UIImage(systemName: icon)
        iconView.tintColor = .mainBlue

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)

        let leftStack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        leftStack.spacing = 12
        leftStack.alignment = .center

        let container = UIStackView(arrangedSubviews: [leftStack, toggle])
        container.axis = .horizontal
        container.distribution = .equalSpacing
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
