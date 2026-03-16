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
        let selectedIcon: String?
        let unselectedIcon: String?
        
        init(title: String, selectedIcon: String? = nil, unselectedIcon: String? = nil) {
            self.title = title
            self.selectedIcon = selectedIcon
            self.unselectedIcon = unselectedIcon
        }
    }
    
    var onSelectionChanged: ((Int) -> Void)?
    
    private let items: [Item]
    private var buttons: [UIButton] = []
    
    private let stackView = UIStackView()
    private let selectionView = UIView()
    
    private var selectionLeadingConstraint: NSLayoutConstraint?
    private var selectionWidthConstraint: NSLayoutConstraint?
    
    private let horizontalInset: CGFloat = 6
    private let verticalInset: CGFloat = 6
    private let interItemSpacing: CGFloat = 8
    
    private(set) var selectedIndex: Int = 0 {
        didSet {
            updateSelection(animated: true)
            onSelectionChanged?(selectedIndex)
        }
    }
    
    init(items: [Item]) {
        self.items = items
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSelection(animated: false)
    }
    
    private func setup() {
        backgroundColor = UIColor.systemGray6
        layer.cornerRadius = 18
        clipsToBounds = true
        
        selectionView.backgroundColor = .white
        selectionView.layer.cornerRadius = 14
        selectionView.layer.shadowColor = UIColor.black.cgColor
        selectionView.layer.shadowOpacity = 0.06
        selectionView.layer.shadowRadius = 8
        selectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionView)
        
        stackView.axis = .horizontal
        stackView.spacing = interItemSpacing
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 56),
            
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: verticalInset),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalInset),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalInset),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalInset),
            
            selectionView.topAnchor.constraint(equalTo: topAnchor, constant: verticalInset),
            selectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -verticalInset)
        ])
        
        selectionLeadingConstraint = selectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalInset)
        selectionWidthConstraint = selectionView.widthAnchor.constraint(equalToConstant: 0)
        
        selectionLeadingConstraint?.isActive = true
        selectionWidthConstraint?.isActive = true
        
        items.enumerated().forEach { index, item in
            let button = UIButton(type: .system)
            button.tag = index
            button.layer.cornerRadius = 14
            button.backgroundColor = .clear
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
            button.semanticContentAttribute = .forceLeftToRight
            button.imageView?.contentMode = .scaleAspectFit
            button.translatesAutoresizingMaskIntoConstraints = false
            
            var config = UIButton.Configuration.plain()
            config.title = item.title
            config.imagePadding = 8
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
            config.baseForegroundColor = .onboardingGray
            
            let iconName = item.unselectedIcon ?? item.selectedIcon
            if let iconName {
                config.image = UIImage(named: iconName)
            }
            
            button.configuration = config
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        updateSelection(animated: false)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }
        selectedIndex = sender.tag
    }
    
    func selectItem(at index: Int) {
        guard buttons.indices.contains(index), index != selectedIndex else { return }
        selectedIndex = index
    }
    
    private func updateSelection(animated: Bool) {
        guard !buttons.isEmpty, buttons.indices.contains(selectedIndex) else { return }
        
        let buttonCount = CGFloat(buttons.count)
        let totalHorizontalInsets = horizontalInset * 2
        let totalSpacing = interItemSpacing * CGFloat(max(buttons.count - 1, 0))
        let buttonWidth = (bounds.width - totalHorizontalInsets - totalSpacing) / buttonCount
        
        let leading = horizontalInset + CGFloat(selectedIndex) * (buttonWidth + interItemSpacing)
        
        selectionLeadingConstraint?.constant = leading
        selectionWidthConstraint?.constant = buttonWidth
        
        for (index, button) in buttons.enumerated() {
            let item = items[index]
            let isSelected = index == selectedIndex
            
            var config = button.configuration
            config?.baseForegroundColor = isSelected ? .mainBlue : .onboardingGray
            
            let iconName = isSelected ? (item.selectedIcon ?? item.unselectedIcon) : (item.unselectedIcon ?? item.selectedIcon)
            if let iconName {
                config?.image = UIImage(named: iconName)
            } else {
                config?.image = nil
            }
            
            button.configuration = config
        }
        
        let animations = {
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.35,
                delay: 0,
                usingSpringWithDamping: 0.82,
                initialSpringVelocity: 0.55,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: animations
            )
        } else {
            animations()
        }
    }
}
