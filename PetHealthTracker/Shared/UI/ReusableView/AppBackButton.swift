//
//  AppBackButton.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 24.03.26.
//

import UIKit

final class AppBackButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        setImage(UIImage(systemName: "chevron.left"), for: .normal)
        tintColor = .label
        backgroundColor = .white
        
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.04
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 3)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 36),
            heightAnchor.constraint(equalToConstant: 36)
        ])
    }
}
