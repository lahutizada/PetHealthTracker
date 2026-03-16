//
//  ProfileChevronRow.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit

final class ProfileChevronRow: UIView {

    var onTap: (() -> Void)?

    private let tapButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .clear
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(icon: String, title: String, value: String? = nil) {
        super.init(frame: .zero)

        let iconView = UIImageView(image: UIImage(systemName: icon))
        iconView.tintColor = .mainBlue

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16)

        let leftStack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        leftStack.spacing = 12
        leftStack.alignment = .center

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.textColor = .systemGray
        valueLabel.font = .systemFont(ofSize: 15, weight: .medium)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = .systemGray3

        let rightItems: [UIView] = value != nil ? [valueLabel, chevron] : [chevron]
        let rightStack = UIStackView(arrangedSubviews: rightItems)
        rightStack.spacing = 6
        rightStack.alignment = .center

        let container = UIStackView(arrangedSubviews: [leftStack, rightStack])
        container.axis = .horizontal
        container.distribution = .equalSpacing
        container.alignment = .center
        container.translatesAutoresizingMaskIntoConstraints = false

        addSubview(container)
        addSubview(tapButton)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            container.topAnchor.constraint(equalTo: topAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            tapButton.topAnchor.constraint(equalTo: topAnchor),
            tapButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            tapButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            tapButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        tapButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
    }

    @objc private func handleTap() {
        onTap?()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
