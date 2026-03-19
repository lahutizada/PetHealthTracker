//
//  ReminderFocusCardView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 19.03.26.
//

import UIKit

final class ReminderFocusCardView: UIView {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        view.layer.cornerRadius = 28
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let captionLabel: UILabel = {
        let label = UILabel()
        label.text = "TODAY'S FOCUS"
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .mainBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .onboardingBlack
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let petsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bellWrapView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bellIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "bell.fill"))
        imageView.tintColor = .mainBlue
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(captionLabel)
        containerView.addSubview(countLabel)
        containerView.addSubview(petsLabel)
        containerView.addSubview(bellWrapView)
        bellWrapView.addSubview(bellIconView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 150),
            
            captionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 22),
            captionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            
            countLabel.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 10),
            countLabel.leadingAnchor.constraint(equalTo: captionLabel.leadingAnchor),
            countLabel.trailingAnchor.constraint(equalTo: bellWrapView.leadingAnchor, constant: -12),
            
            petsLabel.leadingAnchor.constraint(equalTo: captionLabel.leadingAnchor),
            petsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -22),
            
            bellWrapView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 18),
            bellWrapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -18),
            bellWrapView.widthAnchor.constraint(equalToConstant: 48),
            bellWrapView.heightAnchor.constraint(equalToConstant: 48),
            
            bellIconView.centerXAnchor.constraint(equalTo: bellWrapView.centerXAnchor),
            bellIconView.centerYAnchor.constraint(equalTo: bellWrapView.centerYAnchor),
            bellIconView.widthAnchor.constraint(equalToConstant: 20),
            bellIconView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func configure(taskCount: Int, petsText: String) {
        countLabel.text = "\(taskCount) Tasks\nPending"
        petsLabel.text = petsText
    }
}
