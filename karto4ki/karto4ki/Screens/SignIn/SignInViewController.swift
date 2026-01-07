//
//  SignInViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 21.12.2025.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    private let interactor: SignInBusinessLogic
    private let translucentBackgroundView: UIView = UIView()
    private let appleIDButton: UIButton = UIButton(type: .system)
    private let gmailButton: UIButton = UIButton()
    private let orLabel: UILabel = UILabel()
    private let rLine: UIView = UIView()
    private let lLine: UIView = UIView()
    private let getCodeButton: UIButton = UIButton(type: .system)
    private let textField: UITextField = UITextField()
    private var translucentBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    private let emailSmallLabel: UILabel = UILabel()
    private let emailBigLabel: UILabel = UILabel()
    private let cardsLogoView: UIImageView = UIImageView(image: UIImage(named: "logo"))

    private let formStack = UIStackView()
    private let orRow = UIView()

    init(interactor: SignInBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        configureCardsLogoView()
        configureAppleIdButton()
        configureGmailButton()
        configureOrLabel()
        configureLines()
        configureGetCodeButton()
        configureEmailTextField()
        configureEmailSmallLabel()
        configureEmailBigLabel()
        configureFormStack()
        translucentBackgroundView.pinTop(to: formStack.topAnchor, -30)
    }

    private func configureBackground() {
        let background = BackgroundView(with: "background-8")
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

    private func configureCardsLogoView() {
        view.addSubview(cardsLogoView)
        cardsLogoView.contentMode = .scaleAspectFit
        cardsLogoView.pinBottom(to: translucentBackgroundView.topAnchor, 0)
        cardsLogoView.pinLeft(to: view.leadingAnchor, 30)
        cardsLogoView.pinRight(to: view.trailingAnchor, 30)
        cardsLogoView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 15)
    }

    private func configureAppleIdButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .black.withAlphaComponent(0.8)
        config.baseForegroundColor = .white
        config.background.cornerRadius = 25
        var container = AttributeContainer()
        container.font = Fonts.futuraB17
        config.attributedTitle = AttributedString("Продолжить с Apple ID", attributes: container)
        appleIDButton.configuration = config
        appleIDButton.setHeight(50)
    }

    private func configureGmailButton() {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(named: "google")
        config.imagePlacement = .trailing
        config.baseBackgroundColor = .white.withAlphaComponent(0.6)
        config.baseForegroundColor = Colors.lilicBAB6FD
        config.background.cornerRadius = 25
        var container = AttributeContainer()
        container.font = Fonts.futuraB17
        config.attributedTitle = AttributedString("Продолжить с Google", attributes: container)
        gmailButton.configuration = config
        gmailButton.layer.borderWidth = 1
        gmailButton.layer.borderColor = Colors.lilicBAB6FD.cgColor
        gmailButton.layer.cornerRadius = 25
        gmailButton.setHeight(50)
    }

    private func configureOrLabel() {
        orLabel.text = "или"
        orLabel.font = Fonts.futuraM17
        orLabel.textColor = Colors.grayCFCFCF
    }

    private func configureLines() {
        rLine.backgroundColor = Colors.grayCFCFCF
        lLine.backgroundColor = Colors.grayCFCFCF
        rLine.setHeight(1)
        lLine.setHeight(1)
    }

    private func configureGetCodeButton() {
        getCodeButton.setTitle("     Получить код     ", for: .normal)
        getCodeButton.setTitleColor(.white, for: .normal)
        getCodeButton.backgroundColor = Colors.lilicD9D7FF
        getCodeButton.layer.cornerRadius = 25
        getCodeButton.titleLabel?.font = Fonts.futuraB17
        getCodeButton.setHeight(50)
        getCodeButton.addTarget(self, action: #selector(getCode), for: .touchUpInside)
    }

    @objc
    private func getCode() {
        interactor.getCode()
    }

    private func configureEmailTextField() {
        textField.delegate = self
        textField.font = Fonts.futuraM17
        textField.attributedPlaceholder = NSAttributedString(
            string: "email",
            attributes: [NSAttributedString.Key.foregroundColor: Colors.grayD9D9D9]
        )
        textField.textColor = Colors.gray848484
        textField.borderStyle = .none
        textField.backgroundColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.layer.cornerRadius = 25
        textField.setHeight(50)

        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always

        dismissKeyboard()
    }

    private func configureEmailSmallLabel() {
        emailSmallLabel.text = "для создания или входа в аккаунт"
        emailSmallLabel.font = Fonts.futuraB14
        emailSmallLabel.textColor = Colors.lilicBAB6FD
        emailSmallLabel.textAlignment = .center
        emailSmallLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func configureEmailBigLabel() {
        emailBigLabel.text = "Введите почту"
        emailBigLabel.font = Fonts.futuraB22
        emailBigLabel.textColor = Colors.lilicBAB6FD
        emailBigLabel.textAlignment = .center
        emailBigLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    private func configureFormStack() {
        translucentBackgroundView.addSubview(formStack)

        formStack.axis = .vertical
        formStack.alignment = .fill
        formStack.distribution = .fill
        formStack.spacing = 12

        formStack.pinLeft(to: translucentBackgroundView.leadingAnchor, 40)
        formStack.pinRight(to: translucentBackgroundView.trailingAnchor, 40)
        formStack.pinBottom(to: translucentBackgroundView.safeAreaLayoutGuide.bottomAnchor, 15)

        orRow.addSubview(orLabel)
        orRow.addSubview(lLine)
        orRow.addSubview(rLine)

        orLabel.pinCenter(to: orRow)

        lLine.pinLeft(to: orRow.leadingAnchor)
        lLine.pinRight(to: orLabel.leadingAnchor, 10)
        lLine.pinCenterY(to: orLabel.centerYAnchor)

        rLine.pinLeft(to: orLabel.trailingAnchor, 10)
        rLine.pinRight(to: orRow.trailingAnchor)
        rLine.pinCenterY(to: orLabel.centerYAnchor)

        orRow.setHeight(20)

        formStack.addArrangedSubview(emailBigLabel)
        formStack.addArrangedSubview(emailSmallLabel)
        formStack.addArrangedSubview(textField)
        formStack.addArrangedSubview(getCodeButton)
        formStack.addArrangedSubview(orRow)
        formStack.addArrangedSubview(gmailButton)
        formStack.addArrangedSubview(appleIDButton)

        formStack.setCustomSpacing(3, after: emailBigLabel)
        formStack.setCustomSpacing(20, after: emailSmallLabel)
    }

    private func dismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view is UIControl ? false : true
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

        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}
