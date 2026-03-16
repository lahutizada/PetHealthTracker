//
//  GrowthProgressView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 16.03.26.
//

import UIKit

final class GrowthProgressView: UIView {

    private let progressView = UIProgressView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .white
        layer.cornerRadius = 22

        progressView.progressTintColor = .mainBlue
        progressView.trackTintColor = .systemGray5
        progressView.progress = 0.23

        let title = UILabel()
        title.text = "Growth Progress"
        title.font = .systemFont(ofSize: 18, weight: .bold)

        let stack = UIStackView(arrangedSubviews: [
            title,
            progressView
        ])

        stack.axis = .vertical
        stack.spacing = 12

        addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
