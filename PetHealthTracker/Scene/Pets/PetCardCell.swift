//
//  PetCardCell.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 10.03.26.
//

import UIKit

final class PetCardCell: UITableViewCell {
    
    static let identifier = "PetCardCell"
    
    var onSetMainTapped: (() -> Void)?
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 22
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let petImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "pawprint.fill")
        iv.tintColor = .mainBlue
        iv.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 28
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let mainBadgeLabel: UILabel = {
        let label = UILabel()
        label.text = " Main Pet "
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .mainBlue
        label.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.12)
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var setMainButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Set as Main", for: .normal)
        button.setTitleColor(.mainBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        button.layer.cornerRadius = 14
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(setMainTapped), for: .touchUpInside)
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        cardView.addSubview(petImageView)
        cardView.addSubview(nameLabel)
        cardView.addSubview(infoLabel)
        cardView.addSubview(mainBadgeLabel)
        cardView.addSubview(setMainButton)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            petImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            petImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            petImageView.widthAnchor.constraint(equalToConstant: 56),
            petImageView.heightAnchor.constraint(equalToConstant: 56),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            nameLabel.leadingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: setMainButton.leadingAnchor, constant: -10),
            
            infoLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6),
            infoLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            mainBadgeLabel.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 10),
            mainBadgeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            setMainButton.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            setMainButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            setMainButton.widthAnchor.constraint(equalToConstant: 96),
            setMainButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with pet: PetResponse) {
        nameLabel.text = pet.name
        infoLabel.text = "\(pet.species.capitalized) • \(pet.breed ?? "Unknown breed")"
        
        let isMain = pet.isHighlighted == true
        mainBadgeLabel.isHidden = !isMain
        setMainButton.isHidden = isMain
        
        if pet.species.uppercased() == "CAT" {
            petImageView.image = UIImage(systemName: "cat.fill")
        } else {
            petImageView.image = UIImage(systemName: "dog.fill")
        }
    }
    
    @objc private func setMainTapped() {
        onSetMainTapped?()
    }
}
