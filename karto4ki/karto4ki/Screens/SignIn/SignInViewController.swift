//
//  SignInViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 21.12.2025.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {

    private let translucentBackgroundView: UIView = UIView()
    private let appleIDButton: UIButton = UIButton(type: .system)
    private let gmailButton: UIButton = UIButton()
    private let orLabel: UILabel = UILabel()
    private let rLine: UIView = UIView()
    private let lLine: UIView = UIView()
    private let getCodeButton: UIButton = UIButton(type: .system)
    private let textField: UITextField = UITextField()
    private var translucentBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private var appleIdBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardNotifications()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        translucentBackgroundView.roundCorners([.topLeft, .topRight], radius: 60)
    }

    private func configureUI() {
        configureBackground()
        configureTranslucentBackground()
        configureAppleIdButton()
        configureGmailButton()
        configureOrLabel()
        configureLines()
        configureGetCodeButton()
        configureEmailTextField()
        translucentBackgroundView.pinTop(to: textField.topAnchor, -30)
    }

    private func configureBackground() {
        let background = BackgroundView()
        view.addSubview(background)
        background.pin(to: view)
        view.sendSubviewToBack(background)
    }
    
    private func configureTranslucentBackground() {
        translucentBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.addSubview(translucentBackgroundView)
        translucentBackgroundView.pinLeft(to: view.leadingAnchor)
        translucentBackgroundView.pinRight(to: view.trailingAnchor)
        translucentBottomConstraint = translucentBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([translucentBottomConstraint])
    }
    
    private func configureAppleIdButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black
        config.baseForegroundColor = .white
        config.background.cornerRadius = 25
        var container = AttributeContainer()
        container.font = Fonts.futuraB17
        config.attributedTitle = AttributedString("Продолжить с Apple ID", attributes: container)
        appleIDButton.configuration = config
        view.addSubview(appleIDButton)
        appleIDButton.pinLeft(to: view.leadingAnchor, 40)
        appleIDButton.pinRight(to: view.trailingAnchor, 40)
        appleIDButton.setHeight(50)
        appleIdBottomConstraint = appleIDButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 5)
        NSLayoutConstraint.activate([appleIdBottomConstraint])
    }
    
    private func configureGmailButton() {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "google")
        config.imagePlacement = .trailing
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .systemBlue
        config.background.cornerRadius = 25
        var container = AttributeContainer()
        container.font = Fonts.futuraB17
        config.attributedTitle = AttributedString("Продолжить с Google", attributes: container)
        gmailButton.configuration = config
        gmailButton.layer.borderWidth = 1
        gmailButton.layer.borderColor = UIColor.systemBlue.cgColor
        gmailButton.layer.cornerRadius = 25
        view.addSubview(gmailButton)
        gmailButton.pinBottom(to: appleIDButton.topAnchor, 15)
        gmailButton.pinLeft(to: view.leadingAnchor, 40)
        gmailButton.pinRight(to: view.trailingAnchor, 40)
        gmailButton.setHeight(50)
    }
    
    private func configureOrLabel() {
        orLabel.text = "или"
        orLabel.font = Fonts.futuraM17
        orLabel.textColor = Colors.grayCFCFCF
        view.addSubview(orLabel)
        orLabel.pinBottom(to: gmailButton.topAnchor, 15)
        orLabel.pinCenterX(to: view.centerXAnchor)
    }
    
    private func configureLines() {
        rLine.backgroundColor = Colors.grayCFCFCF
        lLine.backgroundColor = Colors.grayCFCFCF
        view.addSubview(rLine)
        view.addSubview(lLine)
        rLine.setHeight(1)
        lLine.setHeight(1)
        rLine.pinRight(to: view.trailingAnchor, 40)
        rLine.pinLeft(to: orLabel.trailingAnchor, 10)
        rLine.pinCenterY(to: orLabel.centerYAnchor)
        lLine.pinRight(to: orLabel.leadingAnchor, 10)
        lLine.pinLeft(to: view.leadingAnchor, 40)
        lLine.pinCenterY(to: orLabel.centerYAnchor)
    }
    
    private func configureGetCodeButton() {
        getCodeButton.setTitle("     Получить код     ", for: .normal)
        getCodeButton.setTitleColor(.white, for: .normal)
        getCodeButton.backgroundColor = Colors.lilicD9D7FF
        getCodeButton.layer.cornerRadius = 25
        getCodeButton.titleLabel?.font = Fonts.futuraB17
        view.addSubview(getCodeButton)
        getCodeButton.setHeight(50)
        getCodeButton.pinBottom(to: orLabel.topAnchor, 15)
        getCodeButton.pinCenterX(to: view.centerXAnchor)
    }
    
    private func configureEmailTextField() {
        textField.delegate = self
        textField.font = Fonts.futuraM17
        textField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedString.Key.foregroundColor: Colors.grayD9D9D9])
        textField.textColor = Colors.gray848484
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 25
        view.addSubview(textField)
        textField.pinBottom(to: getCodeButton.topAnchor, 20)
        textField.pinLeft(to: view.leadingAnchor, 40)
        textField.pinRight(to: view.trailingAnchor, 40)
        textField.setHeight(50)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        dismissKeyboard()
    }
    
    private func dismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }
    
    private func keyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        translucentBottomConstraint.constant = -frame.height
        appleIdBottomConstraint.constant = -frame.height
        
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func keyboardWillHide(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        translucentBottomConstraint.constant = 0
        appleIdBottomConstraint.constant = 0

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
    
    
}

