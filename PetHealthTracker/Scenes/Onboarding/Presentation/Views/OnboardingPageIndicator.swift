//
//  OnboardingPageIndicator.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 06.03.26.
//

import UIKit

final class OnboardingPageIndicator: UIView {

    private struct Indicator {
        let view: UIView
        let width: NSLayoutConstraint
        let height: NSLayoutConstraint
    }

    private var indicators: [Indicator] = []

    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    var pages: Int = 0 {
        didSet {
            guard pages != oldValue else { return }
            setupIndicators()
        }
    }

    var current: Int = 0 {
        didSet {
            updateIndicators()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    private func setupIndicators() {

        indicators.forEach { $0.view.removeFromSuperview() }
        indicators.removeAll()

        for _ in 0..<pages {

            let dot = UIView()
            dot.backgroundColor = UIColor.onboardingGray.withAlphaComponent(0.3)
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false

            let width = dot.widthAnchor.constraint(equalToConstant: 8)
            let height = dot.heightAnchor.constraint(equalToConstant: 8)

            NSLayoutConstraint.activate([width, height])

            stack.addArrangedSubview(dot)

            indicators.append(
                Indicator(
                    view: dot,
                    width: width,
                    height: height
                )
            )
        }

        updateIndicators()
    }

    private func updateIndicators() {

        guard !indicators.isEmpty else { return }

        for (index, indicator) in indicators.enumerated() {

            if index == current {

                indicator.view.backgroundColor = .mainBlue
                indicator.width.constant = 32
                indicator.height.constant = 8

                indicator.view.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)

            } else {

                indicator.view.backgroundColor = UIColor.onboardingGray.withAlphaComponent(0.3)
                indicator.width.constant = 8
                indicator.height.constant = 8

                indicator.view.transform = .identity
            }
        }

        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.45,
            options: [.curveEaseInOut]
        ) {
            self.layoutIfNeeded()
        } completion: { _ in
            guard self.current < self.indicators.count else { return }

            UIView.animate(withDuration: 0.15) {
                self.indicators[self.current].view.transform = .identity
            }
        }
    }
}
