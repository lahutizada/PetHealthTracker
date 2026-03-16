//
//  VetVisitCard.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 16.03.26.
//

import UIKit

final class VetVisitCard: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.cornerRadius = 26

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.mainBlue.cgColor,
            UIColor.systemBlue.cgColor
        ]

        layer.insertSublayer(gradient, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
