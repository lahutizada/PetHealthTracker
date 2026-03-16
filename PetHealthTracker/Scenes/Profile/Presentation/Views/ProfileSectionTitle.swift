//
//  ProfileSectionTitle.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 15.03.26.
//

import UIKit

final class ProfileSectionTitle: UILabel {

    init(text: String) {
        super.init(frame: .zero)
        self.text = text
        font = .systemFont(ofSize: 12, weight: .bold)
        textColor = .systemGray
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init(coder: NSCoder) {
        fatalError()
    }
}
