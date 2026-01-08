//
//  KeyboardObserving.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 08.01.2026.
//

import UIKit

protocol KeyboardAvoiding: AnyObject {
    func keyboardAdjustment(height: CGFloat,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions)
}

extension UIViewController {

    func startKeyboardAvoiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(_kb_willShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(_kb_willHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func stopKeyboardAvoiding() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func _kb_willShow(_ notification: Notification) {
        guard
            let vc = self as? KeyboardAvoiding,
            let userInfo = notification.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        else { return }

        let options = UIView.AnimationOptions(rawValue: UInt(curveRaw << 16))
        vc.keyboardAdjustment(height: frame.height, duration: duration, options: options)
    }

    @objc private func _kb_willHide(_ notification: Notification) {
        guard
            let vc = self as? KeyboardAvoiding,
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curveRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int
        else { return }

        let options = UIView.AnimationOptions(rawValue: UInt(curveRaw << 16))
        vc.keyboardAdjustment(height: 0, duration: duration, options: options)
    }
}
