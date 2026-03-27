//
//  BaseController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 28.02.26.
//

import UIKit

class BaseController: UIViewController {
    
    private lazy var dismissKeyboardTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboardTapped))
        gesture.cancelsTouchesInView = false
        gesture.delegate = self
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureViewModel()
        configureConstraints()
        configureKeyboardDismiss()
    }
    
    func configureUI() {
        
    }
    
    func configureConstraints() {
        
    }
    
    func configureViewModel() {
        
    }
    
    private func configureKeyboardDismiss() {
        view.addGestureRecognizer(dismissKeyboardTapGesture)
    }
    
    @objc private func dismissKeyboardTapped() {
        view.endEditing(true)
    }
}

extension BaseController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        if touch.view is UIControl {
            return false
        }
        
        return true
    }
}
