//
//  RegistrationViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 08.01.2026.
//

import UIKit
final class RegistrationViewController: UIViewController, KeyboardAvoiding, UIGestureRecognizerDelegate {

    private let enterLabel = EnterHeartLabel(with: "имя")
    private let textField = UITextField()

    private var enterTopConstraint: NSLayoutConstraint?
    private var textFieldTopConstraint: NSLayoutConstraint?

    private let baseEnterTop: CGFloat = -100
    private let baseFieldTop: CGFloat = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startKeyboardAvoiding()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopKeyboardAvoiding()
    }

    func keyboardAdjustment(height: CGFloat, duration: TimeInterval, options: UIView.AnimationOptions) {
        view.layoutIfNeeded()

        if height == 0 {
            enterTopConstraint?.constant = baseEnterTop
            UIView.animate(withDuration: duration, delay: 0, options: options) {
                self.view.layoutIfNeeded()
            }
            return
        }

        let keyboardTopY = view.bounds.height - height
        let tfFrame = textField.convert(textField.bounds, to: view)

        // сколько textField залез под клавиатуру
        let overlap = tfFrame.maxY - keyboardTopY

        // если не перекрывает — ничего не делаем
        guard overlap > 0 else { return }

        let padding: CGFloat = 12
        enterTopConstraint?.constant = baseEnterTop - (overlap + padding)

        UIView.animate(withDuration: duration, delay: 0, options: options) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func configureUI() {
        setGesture()
        configureBackground()
        configureEnterLabel()
        configureTextField()
    }
    
    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    private func configureBackground() {
        let background = BackgroundView(with: "background-10")
        view.addSubview(background)
        background.pin(to: view)
        view.sendSubviewToBack(background)
    }

    private func configureEnterLabel() {
        view.addSubview(enterLabel)
        enterLabel.pinCenterX(to: view.centerXAnchor)

        enterTopConstraint = enterLabel.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: baseEnterTop
        )
        enterTopConstraint?.isActive = true
    }

    private func configureTextField() {
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.textAlignment = .left
        textField.layer.backgroundColor = UIColor.white.withAlphaComponent(0.5).cgColor
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 20

        view.addSubview(textField)
        textField.setHeight(40)
        textField.pinLeft(to: view.leadingAnchor, 40)
        textField.pinRight(to: view.trailingAnchor, 40)
        textFieldTopConstraint = textField.topAnchor.constraint(
            equalTo: enterLabel.bottomAnchor,
            constant: baseFieldTop
        )
        textFieldTopConstraint?.isActive = true
    }
}

