//
//  AlertManager.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 09.03.26.
//

import UIKit

struct AlertManager {
    static func showError(on vc: UIViewController, message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        vc.present(alert, animated: true)
    }
}
