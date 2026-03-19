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
    
    private let petCardView = PetCardContentView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(petCardView)
        petCardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            petCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            petCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            petCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            petCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        petCardView.actionButton.addTarget(self, action: #selector(setMainTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with pet: PetResponse) {
        let speciesText = pet.species.uppercased() == "CAT" ? "Cat" : "Dog"
        let breedText = pet.breed ?? "Unknown breed"
        let info = "\(speciesText) • \(breedText)"
        
        let isMain = pet.isHighlighted == true
        
        petCardView.configure(
            name: pet.name,
            info: info,
            photoURL: pet.photoUrl,
            species: pet.species,
            statusText: pet.weight == nil ? "Check weight" : "Up to date",
            isMain: isMain,
            showChevron: true,
            actionTitle: isMain ? nil : "Set as Main"
        )
    }
    
    @objc private func setMainTapped() {
        onSetMainTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        petCardView.petImageView.cancelImageLoad()
    }
}
