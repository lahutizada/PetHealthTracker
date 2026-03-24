//
//  AppButtonFactory.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 23.03.26.
//

import UIKit

enum AppButtonFactory {
    
    static func primary(
        title: String,
        imageSystemName: String? = nil
    ) -> UIButton {
        
        var config = UIButton.Configuration.filled()
        config.title = title
        
        if let imageSystemName {
            config.image = UIImage(systemName: imageSystemName)
            config.imagePlacement = .leading
            config.imagePadding = 6
        }
        
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 14,
            leading: 18,
            bottom: 14,
            trailing: 18
        )
        
        config.baseBackgroundColor = .mainBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        
        config.attributedTitle = AttributedString(
            title,
            attributes: AttributeContainer([
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold)
            ])
        )
        
        let button = UIButton(configuration: config)
        button.clipsToBounds = true
        return button
    }
}
