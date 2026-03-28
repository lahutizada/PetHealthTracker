//
//  BaseController.swift
//  PetHealthTracker
//
//  Created by Ruslan Lahutizada on 28.02.26.
//

import UIKit

class BaseController: UIViewController {
    
    // MARK: - Keyboard
    
    var keyboardScrollView: UIScrollView? { nil }
    
    private var keyboardObserversAdded = false
    private var originalContentInset: UIEdgeInsets?
    private var originalIndicatorInset: UIEdgeInsets?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        configureConstraints()
        configureViewModel()
        configureTapToDismissKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !keyboardObserversAdded {
            keyboardObserversAdded = true
            addKeyboardObservers()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        restoreKeyboardState()
        view.endEditing(true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Override points
    
    func configureUI() {}
    func configureConstraints() {}
    func configureViewModel() {}
    
    // MARK: - Setup
    
    private func configureTapToDismissKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleKeyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Actions
    
    @objc private func handleBackgroundTap() {
        view.endEditing(true)
    }
    
    @objc private func handleKeyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }
        
        let keyboardFrameInScreen = keyboardFrameValue.cgRectValue
        let keyboardFrameInView = view.convert(keyboardFrameInScreen, from: nil)
        let keyboardHeight = max(
            0,
            view.bounds.maxY - keyboardFrameInView.minY - view.safeAreaInsets.bottom
        )
        
        if let scrollView = keyboardScrollView {
            if originalContentInset == nil {
                originalContentInset = scrollView.contentInset
            }
            
            if originalIndicatorInset == nil {
                originalIndicatorInset = scrollView.verticalScrollIndicatorInsets
            }
            
            let baseContentInset = originalContentInset ?? .zero
            let baseIndicatorInset = originalIndicatorInset ?? .zero
            let extraSpacing: CGFloat = 4
            
            var newContentInset = baseContentInset
            newContentInset.bottom = baseContentInset.bottom + keyboardHeight + extraSpacing
            
            var newIndicatorInset = baseIndicatorInset
            newIndicatorInset.bottom = baseIndicatorInset.bottom + keyboardHeight + extraSpacing
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: UIView.AnimationOptions(rawValue: curveRaw << 16),
                animations: {
                    scrollView.contentInset = newContentInset
                    scrollView.verticalScrollIndicatorInsets = newIndicatorInset
                }
            )
            
            guard let responder = findFirstResponder(in: view) else { return }
            
            let responderFrame = responder.convert(responder.bounds, to: scrollView)
            scrollView.scrollRectToVisible(
                responderFrame.insetBy(dx: 0, dy: -12),
                animated: true
            )
        } else {
            guard let responder = findFirstResponder(in: view) else { return }
            
            let responderFrame = responder.convert(responder.bounds, to: view)
            let overlap = responderFrame.maxY + 20 - keyboardFrameInView.minY
            
            guard overlap > 0, view.frame.origin.y == 0 else { return }
            
            UIView.animate(
                withDuration: duration,
                delay: 0,
                options: UIView.AnimationOptions(rawValue: curveRaw << 16),
                animations: {
                    self.view.frame.origin.y = -overlap
                }
            )
        }
    }
    
    @objc private func handleKeyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else {
            restoreKeyboardState()
            return
        }
        
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: UIView.AnimationOptions(rawValue: curveRaw << 16),
            animations: {
                self.restoreKeyboardState()
            }
        )
    }
    
    // MARK: - Helpers
    
    private func restoreKeyboardState() {
        if let scrollView = keyboardScrollView {
            let restoredContentInset = originalContentInset ?? .zero
            let restoredIndicatorInset = originalIndicatorInset ?? .zero
            
            scrollView.contentInset = restoredContentInset
            scrollView.verticalScrollIndicatorInsets = restoredIndicatorInset
            
            let minOffsetY = -scrollView.adjustedContentInset.top
            let maxOffsetY = max(
                minOffsetY,
                scrollView.contentSize.height - scrollView.bounds.height + scrollView.adjustedContentInset.bottom
            )
            
            var offset = scrollView.contentOffset
            offset.y = min(max(offset.y, minOffsetY), maxOffsetY)
            scrollView.setContentOffset(offset, animated: false)
            
            originalContentInset = nil
            originalIndicatorInset = nil
        } else {
            view.frame.origin.y = 0
        }
    }
    
    private func findFirstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        }
        
        for subview in view.subviews {
            if let responder = findFirstResponder(in: subview) {
                return responder
            }
        }
        
        return nil
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BaseController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        return true
    }
}
