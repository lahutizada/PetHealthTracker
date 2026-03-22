//
//  ReminderFocusCardView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class ReminderFocusCardView: UIView {
    
    private var petsTextLabelLeadingToFirstPetConstraint: NSLayoutConstraint!
    private var petsTextLabelLeadingToSecondPetConstraint: NSLayoutConstraint!
    private var petsTextLabelLeadingToContainerConstraint: NSLayoutConstraint!
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        view.layer.cornerRadius = 30
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let eyebrowLabel: UILabel = {
        let label = UILabel()
        label.text = "TODAY'S FOCUS"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .mainBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "0 Tasks\nPending"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bellWrap: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 34
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.04
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bellIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "bell.fill"))
        imageView.tintColor = .mainBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let firstPetImageView = ReminderFocusCardView.makePetImageView()
    private let secondPetImageView = ReminderFocusCardView.makePetImageView()
    
    private let petsTextLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .onboardingGray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private static func makePetImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(containerView)
        
        containerView.addSubview(eyebrowLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(bellWrap)
        bellWrap.addSubview(bellIcon)
        
        containerView.addSubview(firstPetImageView)
        containerView.addSubview(secondPetImageView)
        containerView.addSubview(petsTextLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 190),
            
            eyebrowLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 28),
            eyebrowLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 28),
            
            titleLabel.topAnchor.constraint(equalTo: eyebrowLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: eyebrowLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -120),
            
            bellWrap.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            bellWrap.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            bellWrap.widthAnchor.constraint(equalToConstant: 68),
            bellWrap.heightAnchor.constraint(equalToConstant: 68),
            
            bellIcon.centerXAnchor.constraint(equalTo: bellWrap.centerXAnchor),
            bellIcon.centerYAnchor.constraint(equalTo: bellWrap.centerYAnchor),
            bellIcon.widthAnchor.constraint(equalToConstant: 24),
            bellIcon.heightAnchor.constraint(equalToConstant: 24),
            
            firstPetImageView.leadingAnchor.constraint(equalTo: eyebrowLabel.leadingAnchor),
            firstPetImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -26),
            firstPetImageView.widthAnchor.constraint(equalToConstant: 40),
            firstPetImageView.heightAnchor.constraint(equalToConstant: 40),
            
            secondPetImageView.leadingAnchor.constraint(equalTo: firstPetImageView.trailingAnchor, constant: -10),
            secondPetImageView.centerYAnchor.constraint(equalTo: firstPetImageView.centerYAnchor),
            secondPetImageView.widthAnchor.constraint(equalToConstant: 40),
            secondPetImageView.heightAnchor.constraint(equalToConstant: 40),
            
            petsTextLabel.centerYAnchor.constraint(equalTo: firstPetImageView.centerYAnchor),
            petsTextLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -28)
        ])
        
        petsTextLabelLeadingToFirstPetConstraint = petsTextLabel.leadingAnchor.constraint(equalTo: firstPetImageView.trailingAnchor, constant: 10)
        petsTextLabelLeadingToSecondPetConstraint = petsTextLabel.leadingAnchor.constraint(equalTo: secondPetImageView.trailingAnchor, constant: 14)
        petsTextLabelLeadingToContainerConstraint = petsTextLabel.leadingAnchor.constraint(equalTo: eyebrowLabel.leadingAnchor)
        
        petsTextLabelLeadingToContainerConstraint.isActive = true
    }
    
    func configure(taskCount: Int, petsText: String, pets: [ReminderFocusPet]) {
        titleLabel.text = "\(taskCount) Tasks\nPending"
        petsTextLabel.text = petsText
        
        let firstPet = pets.indices.contains(0) ? pets[0] : nil
        let secondPet = pets.indices.contains(1) ? pets[1] : nil
        
        configurePetImageView(firstPetImageView, with: firstPet)
        configurePetImageView(secondPetImageView, with: secondPet)
        updatePetsTextPosition(firstPet: firstPet, secondPet: secondPet)
    }
    
    private func updatePetsTextPosition(firstPet: ReminderFocusPet?, secondPet: ReminderFocusPet?) {
        petsTextLabelLeadingToFirstPetConstraint.isActive = false
        petsTextLabelLeadingToSecondPetConstraint.isActive = false
        petsTextLabelLeadingToContainerConstraint.isActive = false
        
        if secondPet != nil {
            petsTextLabelLeadingToSecondPetConstraint.isActive = true
        } else if firstPet != nil {
            petsTextLabelLeadingToFirstPetConstraint.isActive = true
        } else {
            petsTextLabelLeadingToContainerConstraint.isActive = true
        }
        
        layoutIfNeeded()
    }
    
    private func configurePetImageView(_ imageView: UIImageView, with pet: ReminderFocusPet?) {
        guard let pet else {
            imageView.isHidden = true
            imageView.cancelImageLoad()
            imageView.image = nil
            return
        }
        
        imageView.isHidden = false
        
        if let photoURL = pet.photoURL, let url = URL(string: photoURL) {
            imageView.cancelImageLoad()
            imageView.contentMode = .scaleAspectFill
            imageView.backgroundColor = .white
            imageView.tintColor = nil
            imageView.setImage(from: url)
        } else {
            imageView.cancelImageLoad()
            imageView.image = UIImage(systemName: "pawprint.fill")
            imageView.tintColor = .mainBlue
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = .white
        }
    }
}
