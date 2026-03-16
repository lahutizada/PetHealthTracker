//
//  PetStatCardView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 16.03.26.
//

import UIKit

final class PetStatCardView: UIView {

    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let unitLabel = UILabel()

    init(title: String) {
        super.init(frame: .zero)

        backgroundColor = .white
        layer.cornerRadius = 22

        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = .onboardingGray
        titleLabel.textAlignment = .center

        valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
        valueLabel.textColor = .onboardingBlack
        valueLabel.textAlignment = .center

        unitLabel.font = .systemFont(ofSize: 14)
        unitLabel.textColor = .onboardingGray

        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .horizontal
        valueStack.spacing = 4
        valueStack.alignment = .center
        valueStack.distribution = .fill

        let stack = UIStackView(arrangedSubviews: [titleLabel, valueStack])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .center

        addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func configure(value: String, unit: String) {
        valueLabel.text = value
        unitLabel.text = unit
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
