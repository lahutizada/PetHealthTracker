//
//  ProfileCardView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit

final class ProfileCardView: UIStackView {

    init() {
        super.init(frame: .zero)
        axis = .vertical
        spacing = 0
        backgroundColor = .white
        layer.cornerRadius = 18
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init(coder: NSCoder) {
        fatalError()
    }

    override func addArrangedSubview(_ row: UIView) {
        super.addArrangedSubview(row)
        row.heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
}
