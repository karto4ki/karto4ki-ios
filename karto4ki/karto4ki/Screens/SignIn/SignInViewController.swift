//
//  SignInViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 21.12.2025.
//

import UIKit
import AuthenticationServices
import GoogleSignIn

final class SignInViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    private let interactor: SignInBusinessLogic
    private let heart = UILabel()
    private let appleIDButton: UIButton = UIButton(type: .system)
    private let gmailButton: UIButton = UIButton()
    private let orLabel: UILabel = UILabel()
    private let rLine: UIView = UIView()
    private let lLine: UIView = UIView()
    private let getCodeButton: UIButton = UIButton(type: .system)
    private let textField: UITextField = UITextField()
    private let welcomeLabel: UILabel = UILabel()
    private let emailLabel: UILabel = UILabel()
    private let cardsLogoView: UIImageView = UIImageView(image: UIImage(named: "logo"))

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
        configureUI()
    }

    private func configureUI() {
        configureBackground()
        configureAppleIdButton()
        configureGmailButton()
        configureOrLabel()
        configureLines()
        configureGetCodeButton()
        configureEmailTextField()
        configureEmailLabel()
        configureWelcomeLabel()
        configureHeart()
        configureCardsLogoView()
    }

    private func configureBackground() {
        let background = BackgroundView(with: "background-6")
        view.addSubview(background)
        background.pin(to: view)
        view.sendSubviewToBack(background)
        background.isUserInteractionEnabled = false
    }

    private func configureCardsLogoView() {
        view.addSubview(cardsLogoView)
        cardsLogoView.contentMode = .scaleAspectFit
        cardsLogoView.pinLeft(to: view.leadingAnchor, 30)
        cardsLogoView.pinRight(to: view.trailingAnchor, 30)
        cardsLogoView.pinBottom(to: heart.topAnchor, -120)
    }

    private func configureHeart() {
        heart.text = "."
        heart.font = UIFont(name: "Musinka-Regular", size: 300)
        heart.textColor = .white
        heart.textAlignment = .center
        view.addSubview(heart)
        heart.pinBottom(to: welcomeLabel.topAnchor, -20)
        heart.pinCenterX(to: view.centerXAnchor)
    }

    private func configureWelcomeLabel() {
        welcomeLabel.text = "Добро пожаловать"
        welcomeLabel.font = Fonts.futuraB22
        welcomeLabel.textColor = .white
        welcomeLabel.textAlignment = .center
        view.addSubview(welcomeLabel)
        welcomeLabel.pinBottom(to: emailLabel.topAnchor, -5)
        welcomeLabel.pinCenterX(to: view.centerXAnchor)
    }

    private func configureEmailLabel() {
        emailLabel.text = "Введите почту"
        emailLabel.font = Fonts.phantom
        emailLabel.textColor = .white
        emailLabel.textAlignment = .center
        view.addSubview(emailLabel)
        emailLabel.pinBottom(to: textField.topAnchor, 30)
        emailLabel.pinCenterX(to: view.centerXAnchor)
    }

    private func configureEmailTextField() {
        textField.delegate = self
        textField.font = Fonts.futuraM17
        textField.attributedPlaceholder = NSAttributedString(
            string: "email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.8)]
        )
        textField.textColor = .white
        textField.borderStyle = .none
        textField.layer.cornerRadius = 25
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.cgColor
        textField.backgroundColor = .white.withAlphaComponent(0.2)
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

        view.addSubview(textField)
        textField.pinBottom(to: getCodeButton.topAnchor, 15)
        textField.pinLeft(to: view.leadingAnchor, 40)
        textField.pinRight(to: view.trailingAnchor, 40)
    }

    private func configureGetCodeButton() {
        getCodeButton.setTitle("     Получить код     ", for: .normal)
        getCodeButton.setTitleColor(.white, for: .normal)
        getCodeButton.backgroundColor = Colors.lilicBAB6FD.withAlphaComponent(0.4)
        getCodeButton.layer.cornerRadius = 25
        getCodeButton.layer.borderWidth = 1
        getCodeButton.layer.borderColor = Colors.lilicBAB6FD.cgColor
        getCodeButton.titleLabel?.font = UIFont(name: "futuralt-bold", size: 20)
        getCodeButton.setHeight(50)
        getCodeButton.addTarget(self, action: #selector(getCode), for: .touchUpInside)
        view.addSubview(getCodeButton)
        getCodeButton.pinBottom(to: orLabel.topAnchor, 15)
        getCodeButton.pinLeft(to: view.leadingAnchor, 40)
        getCodeButton.pinRight(to: view.trailingAnchor, 40)
    }

    private func configureOrLabel() {
        orLabel.text = "или"
        orLabel.font = Fonts.futuraB20
        orLabel.textColor = .white
        view.addSubview(orLabel)
        orLabel.pinBottom(to: gmailButton.topAnchor, 15)
        orLabel.pinCenterX(to: view.centerXAnchor, 0)
    }

    private func configureLines() {
        rLine.backgroundColor = .white
        lLine.backgroundColor = .white
        rLine.setHeight(1)
        lLine.setHeight(1)
        view.addSubview(rLine)
        view.addSubview(lLine)

        lLine.pinCenterY(to: orLabel.centerYAnchor)
        rLine.pinCenterY(to: orLabel.centerYAnchor)
        lLine.pinRight(to: orLabel.leadingAnchor, 10)
        rLine.pinLeft(to: orLabel.trailingAnchor, 10)
        lLine.pinLeft(to: view.leadingAnchor, 40)
        rLine.pinRight(to: view.trailingAnchor, 40)
    }

    private func configureGmailButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white.withAlphaComponent(0.2)
        config.baseForegroundColor = .white.withAlphaComponent(0.9)
        config.background.cornerRadius = 25
        var container = AttributeContainer()
        container.font = UIFont(name: "futuralt-bold", size: 20)
        config.attributedTitle = AttributedString("Продолжить с Google", attributes: container)
        gmailButton.configuration = config
        gmailButton.layer.borderWidth = 1
        gmailButton.layer.borderColor = UIColor.white.cgColor
        gmailButton.layer.cornerRadius = 25
        gmailButton.setHeight(50)
        gmailButton.addTarget(self, action: #selector(signInWithGoogleTapped), for: .touchUpInside)
        view.addSubview(gmailButton)
        gmailButton.pinBottom(to: appleIDButton.topAnchor, 15)
        gmailButton.pinLeft(to: view.leadingAnchor, 40)
        gmailButton.pinRight(to: view.trailingAnchor, 40)
    }

    private func configureAppleIdButton() {
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .white.withAlphaComponent(0.2)
        config.baseForegroundColor = .white.withAlphaComponent(0.9)
        config.background.cornerRadius = 25
        var container = AttributeContainer()
        container.font = UIFont(name: "futuralt-bold", size: 20)
        config.attributedTitle = AttributedString("Продолжить с Apple ID", attributes: container)
        appleIDButton.configuration = config
        appleIDButton.setHeight(50)
        appleIDButton.layer.borderWidth = 1
        appleIDButton.layer.borderColor = UIColor.white.cgColor
        appleIDButton.layer.cornerRadius = 25
        appleIDButton.addTarget(self, action: #selector(signInWithAppleTapped), for: .touchUpInside)

        view.addSubview(appleIDButton)
        appleIDButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            appleIDButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            appleIDButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            appleIDButton.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -60),
            appleIDButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc
    private func getCode() {
        guard let email = textField.text, !email.isEmpty else { return }
        interactor.getCode(email)
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
}

extension SignInViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {

    @objc
    private func signInWithAppleTapped() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        view.window ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else { return }

        let userId = credential.user
        let email = credential.email
        let fullName = credential.fullName

        let identityToken = credential.identityToken.flatMap { String(data: $0, encoding: .utf8) }
        let authCode = credential.authorizationCode.flatMap { String(data: $0, encoding: .utf8) }

        interactor.signInWithApple(
            userId: userId,
            email: email,
            fullName: fullName,
            identityToken: identityToken,
            authorizationCode: authCode
        )
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        interactor.appleSignInFailed(error)
    }
}

extension SignInViewController {

    @objc
    private func signInWithGoogleTapped() {
        guard let presentingVC = view.window?.rootViewController ?? self as UIViewController? else { return }

        GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
            if let error = error {
                self.interactor.googleSignInFailed(error)
                return
            }

            guard let result = result else { return }

            let user = result.user
            let idToken = user.idToken?.tokenString
            let accessToken = user.accessToken.tokenString

            self.interactor.signInWithGoogle(
                idToken: idToken,
                accessToken: accessToken
            )
        }
    }
}
