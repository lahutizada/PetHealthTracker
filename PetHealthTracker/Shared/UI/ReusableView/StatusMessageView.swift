//
//  StatusMessageView.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 18.03.26.
//

import UIKit

final class StatusMessageView: UIView {
    
    enum Style {
        case success
        case error
        case info
        case warning
    }
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        layer.cornerRadius = 16
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(iconView)
        addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),
            
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    func show(message: String, style: Style) {
        messageLabel.text = message
        
        switch style {
        case .success:
            messageLabel.textColor = .systemGreen
            iconView.image = UIImage(systemName: "checkmark.circle.fill")
            iconView.tintColor = .systemGreen
            backgroundColor = UIColor.systemGreen.withAlphaComponent(0.10)
            
        case .error:
            messageLabel.textColor = .systemRed
            iconView.image = UIImage(systemName: "exclamationmark.circle.fill")
            iconView.tintColor = .systemRed
            backgroundColor = UIColor.systemRed.withAlphaComponent(0.10)
            
        case .info:
            messageLabel.textColor = .systemBlue
            iconView.image = UIImage(systemName: "info.circle.fill")
            iconView.tintColor = .systemBlue
            backgroundColor = UIColor.systemBlue.withAlphaComponent(0.10)
            
        case .warning:
            messageLabel.textColor = .systemOrange
            iconView.image = UIImage(systemName: "exclamationmark.triangle.fill")
            iconView.tintColor = .systemOrange
            backgroundColor = UIColor.systemOrange.withAlphaComponent(0.10)
        }
        
        alpha = 0
        isHidden = false
        
        UIView.animate(withDuration: 0.22) {
            self.alpha = 1
        }
    }
    
    func hide() {
        guard !isHidden else { return }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
            self.messageLabel.text = nil
        }
    }
}
