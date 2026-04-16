//
//  RegistrationViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 08.01.2026.
//

import UIKit

final class RegistrationViewController: UIViewController, UIGestureRecognizerDelegate {

    private let enterLabel = EnterHeartLabel(with: "имя")
    private let textField = UITextField()
    private var name: String?
    private let interactor: RegistrationBusinessLogic
    private let contentGuide: UILayoutGuide = UILayoutGuide()

    private let nameButton = UIButton(type: .system)

    init(interactor: RegistrationInteractor) {
        self.interactor = interactor
        super.init(nibName: .none, bundle: .none)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func configureUI() {
        setGesture()
        configureLayoutGuide()
        configureBackground()
        configureEnterLabel()
        configureTextField()
        configureNameButton()
    }

    private func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }
    
    private func configureLayoutGuide() {
        view.addLayoutGuide(contentGuide)
        
        NSLayoutConstraint.activate([
            contentGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentGuide.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            contentGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
    }

    private func configureBackground() {
        let background = BackgroundView()
        view.addSubview(background)
        background.pin(to: view)
        view.sendSubviewToBack(background)
    }

    private func configureEnterLabel() {
        view.addSubview(enterLabel)
        enterLabel.pinCenterX(to: view.centerXAnchor)
        enterLabel.pinTop(to: contentGuide.topAnchor, -100)
    }

    private func configureTextField() {
        textField.borderStyle = .none
        textField.autocapitalizationType = .none
        textField.textAlignment = .left
        textField.layer.backgroundColor = UIColor.white.withAlphaComponent(0.5).cgColor
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 25
        textField.autocorrectionType = .no
        textField.font = UIFont(name: "Musinka-Regular", size: 40)
        textField.textColor = UIColor(red: 187/255, green: 174/255, blue: 255/255, alpha: 1)

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.leftView = paddingView
        textField.rightView = paddingView
        textField.rightViewMode = .always
        textField.leftViewMode = .always
        textField.delegate = self
        textField.returnKeyType = .done

        view.addSubview(textField)
        textField.setHeight(50)
        textField.pinLeft(to: view.leadingAnchor, 40)
        textField.pinRight(to: view.trailingAnchor, 40)
        textField.pinTop(to: enterLabel.bottomAnchor, 30)
    }

    private func configureNameButton() {
        var config = UIButton.Configuration.plain()

        config.background.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        config.background.cornerRadius = 25
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)

        nameButton.configuration = config
        nameButton.titleLabel?.numberOfLines = 3
        nameButton.titleLabel?.lineBreakMode = .byCharWrapping
        nameButton.titleLabel?.textAlignment = .center
        nameButton.isHidden = true
        nameButton.addTarget(self, action: #selector(updateWithName), for: .touchUpInside)

        view.addSubview(nameButton)
        nameButton.pinLeft(to: view.leadingAnchor, 40)
        nameButton.pinRight(to: view.trailingAnchor, 40)
        nameButton.pinTop(to: contentGuide.topAnchor, 20)
    }

    private func setNameButtonTitle(_ text: String) {
        guard var config = nameButton.configuration else { return }

        var attrs = AttributeContainer()
        attrs.font = UIFont(name: "Musinka-Regular", size: 40) ?? .systemFont(ofSize: 40)
        attrs.foregroundColor = UIColor(red: 255/255, green: 174/255, blue: 213/255, alpha: 1)

        config.attributedTitle = AttributedString("имя: \(text)", attributes: attrs)
        nameButton.configuration = config
        nameButton.titleLabel?.numberOfLines = 3
    }

    private func updateWithNickname() {
        dismissKeyboard()

        setNameButtonTitle(name ?? "")
        nameButton.alpha = 0
        nameButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        nameButton.isHidden = false

        UIView.transition(
            with: enterLabel.wordLabel,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) {
            self.enterLabel.wordLabel.text = "ник"
        }

        UIView.animate(
            withDuration: 0.4,
            delay: 0.1,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.6
        ) {
            self.nameButton.alpha = 1
            self.nameButton.transform = .identity
        }

        textField.text = ""
    }
    
    @objc
    private func updateWithName() {
        dismissKeyboard()
        
        UIView.transition(
            with: enterLabel.wordLabel,
            duration: 0.25,
            options: .transitionCrossDissolve
        ) {
            self.enterLabel.wordLabel.text = "имя"
        }

        UIView.animate(
            withDuration: 0.4,
            delay: 0.1,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.6
        ) {
            self.nameButton.alpha = 0
            self.nameButton.transform = .identity
        }

        textField.text = ""
    }
    
    private func update(isName: Bool) {
        if isName {
            updateWithName()
        } else {
            updateWithNickname()
        }
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.textField == textField, let text = textField.text {
            if enterLabel.wordLabel.text == "имя" {
                name = text
                updateWithNickname()
            } else {
                dismissKeyboard()
                let goBack = { [weak self] (isName: Bool) in
                    self?.update(isName: isName)
                }
                let routing = { [weak self] (name: String, username: String) in
                    self?.interactor.confirm(name: name, username: username)
                }
                interactor.goToConfirmation(name: name ?? "", username: text, goBackClosure: goBack, routingClosure: routing)
            }
        }
        return true
    }
}
