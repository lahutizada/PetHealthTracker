//
//  PetOptionToggleView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import UIKit

final class PetOptionToggleView: UIView {
    
    struct Item {
        let title: String
    }
    
    var onSelectionChanged: ((Int) -> Void)?
    
    private var buttons: [UIButton] = []
    private var stackView = UIStackView()
    
    private(set) var selectedIndex: Int = 0 {
        didSet {
            updateSelection()
            onSelectionChanged?(selectedIndex)
        }
    }
    
    init(items: [Item]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup(items: items)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(items: [Item]) {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 18
        clipsToBounds = true
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
            heightAnchor.constraint(equalToConstant: 56)
        ])
        
        items.enumerated().forEach { index, item in
            let button = UIButton(type: .system)
            button.setTitle(item.title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            button.layer.cornerRadius = 14
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        updateSelection()
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
    }
    
    func setSelectedIndex(_ index: Int) {
        selectedIndex = index
    }
    
    private func updateSelection() {
        for (index, button) in buttons.enumerated() {
            if index == selectedIndex {
                button.backgroundColor = .white
                button.setTitleColor(.mainBlue, for: .normal)
                button.layer.shadowColor = UIColor.black.cgColor
                button.layer.shadowOpacity = 0.06
                button.layer.shadowRadius = 8
                button.layer.shadowOffset = CGSize(width: 0, height: 2)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(.onboardingGray, for: .normal)
                button.layer.shadowOpacity = 0
            }
        }
    }
}
