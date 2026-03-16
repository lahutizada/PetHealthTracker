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
        view.layer.cornerRadius = 24
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.05
        view.layer.shadowRadius = 14
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
        iv.layer.cornerRadius = 34
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let statusIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 13
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let statusIndicatorIcon: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .onboardingBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let breedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .onboardingGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusBadgeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
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
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.right"))
        iv.tintColor = UIColor.systemGray3
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(cardView)
        
        cardView.addSubview(petImageView)
        cardView.addSubview(statusIndicatorView)
        statusIndicatorView.addSubview(statusIndicatorIcon)
        
        cardView.addSubview(nameLabel)
        cardView.addSubview(breedLabel)
        cardView.addSubview(statusBadgeLabel)
        cardView.addSubview(mainBadgeLabel)
        cardView.addSubview(setMainButton)
        cardView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            petImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            petImageView.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            petImageView.widthAnchor.constraint(equalToConstant: 68),
            petImageView.heightAnchor.constraint(equalToConstant: 68),
            
            statusIndicatorView.widthAnchor.constraint(equalToConstant: 26),
            statusIndicatorView.heightAnchor.constraint(equalToConstant: 26),
            statusIndicatorView.trailingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 4),
            statusIndicatorView.bottomAnchor.constraint(equalTo: petImageView.bottomAnchor, constant: 4),
            
            statusIndicatorIcon.centerXAnchor.constraint(equalTo: statusIndicatorView.centerXAnchor),
            statusIndicatorIcon.centerYAnchor.constraint(equalTo: statusIndicatorView.centerYAnchor),
            statusIndicatorIcon.widthAnchor.constraint(equalToConstant: 12),
            statusIndicatorIcon.heightAnchor.constraint(equalToConstant: 12),
            
            chevronImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            chevronImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 26),
            chevronImageView.widthAnchor.constraint(equalToConstant: 14),
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),
            
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
            nameLabel.leadingAnchor.constraint(equalTo: petImageView.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -12),
            
            breedLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            breedLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            breedLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            
            statusBadgeLabel.topAnchor.constraint(equalTo: breedLabel.bottomAnchor, constant: 14),
            statusBadgeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            statusBadgeLabel.heightAnchor.constraint(equalToConstant: 32),
            
            mainBadgeLabel.topAnchor.constraint(equalTo: statusBadgeLabel.bottomAnchor, constant: 10),
            mainBadgeLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            setMainButton.centerYAnchor.constraint(equalTo: statusBadgeLabel.centerYAnchor),
            setMainButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            setMainButton.widthAnchor.constraint(equalToConstant: 96),
            setMainButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with pet: PetResponse) {
        nameLabel.text = pet.name
        breedLabel.text = pet.breed ?? "Unknown breed"
        
        let isMain = pet.isHighlighted == true
        mainBadgeLabel.isHidden = !isMain
        setMainButton.isHidden = isMain
        
        configureStatus(with: pet)
        configureImage(with: pet)
    }
    
    private func configureStatus(with pet: PetResponse) {
        let status = PetCardStatus(apiValue: pet.status)
        
        statusBadgeLabel.text = "  \(pet.statusText ?? status.title)  "
        statusBadgeLabel.textColor = status.textColor
        statusBadgeLabel.backgroundColor = status.backgroundColor
        
        statusIndicatorView.backgroundColor = status.indicatorColor
        statusIndicatorIcon.image = UIImage(systemName: status.indicatorSymbol)
        
        let targetWidth = max(120, (pet.statusText ?? status.title).size(withAttributes: [
            .font: UIFont.systemFont(ofSize: 15, weight: .semibold)
        ]).width + 28)
        
        if let widthConstraint = statusBadgeLabel.constraints.first(where: { $0.firstAttribute == .width }) {
            widthConstraint.constant = targetWidth
        } else {
            statusBadgeLabel.widthAnchor.constraint(equalToConstant: targetWidth).isActive = true
        }
    }
    
    private func configureImage(with pet: PetResponse) {
        if let photoUrl = pet.photoUrl,
           let url = URL(string: photoUrl) {
            petImageView.tintColor = nil
            petImageView.contentMode = .scaleAspectFill
            petImageView.backgroundColor = UIColor.systemGray6
            petImageView.setImage(from: url)
        } else {
            petImageView.cancelImageLoad()
            petImageView.contentMode = .scaleAspectFit
            petImageView.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
            
            if pet.species.uppercased() == "CAT" {
                petImageView.image = UIImage(named: "cat.standard") ?? UIImage(systemName: "cat.fill")
            } else {
                petImageView.image = UIImage(named: "dog.standard") ?? UIImage(systemName: "dog.fill")
            }
            
            petImageView.tintColor = .mainBlue
        }
    }
    
    @objc private func setMainTapped() {
        onSetMainTapped?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        petImageView.cancelImageLoad()
        petImageView.image = nil
        petImageView.tintColor = .mainBlue
        petImageView.contentMode = .scaleAspectFit
        petImageView.backgroundColor = UIColor.mainBlue.withAlphaComponent(0.08)
        
        statusBadgeLabel.text = nil
        mainBadgeLabel.isHidden = true
        setMainButton.isHidden = false
    }
}

private enum PetCardStatus {
    case upToDate
    case vaccineDue
    case checkWeight
    
    init(apiValue: String?) {
        switch apiValue {
        case "VACCINE_DUE":
            self = .vaccineDue
        case "CHECK_WEIGHT":
            self = .checkWeight
        default:
            self = .upToDate
        }
    }
    
    var title: String {
        switch self {
        case .upToDate:
            return "Up to date"
        case .vaccineDue:
            return "Vaccine due"
        case .checkWeight:
            return "Check weight"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .upToDate:
            return UIColor.systemGray
        case .vaccineDue:
            return UIColor.mainBlue
        case .checkWeight:
            return UIColor.systemOrange
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .upToDate:
            return UIColor.systemGray.withAlphaComponent(0.12)
        case .vaccineDue:
            return UIColor.mainBlue.withAlphaComponent(0.12)
        case .checkWeight:
            return UIColor.systemOrange.withAlphaComponent(0.14)
        }
    }
    
    var indicatorColor: UIColor {
        switch self {
        case .upToDate:
            return UIColor.systemGreen
        case .vaccineDue:
            return UIColor.mainBlue
        case .checkWeight:
            return UIColor.systemOrange
        }
    }
    
    var indicatorSymbol: String {
        switch self {
        case .upToDate:
            return "checkmark"
        case .vaccineDue:
            return "circle.fill"
        case .checkWeight:
            return "exclamationmark"
        }
    }
}
