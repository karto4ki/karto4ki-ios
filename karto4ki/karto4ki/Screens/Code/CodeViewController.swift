//
//  CodeViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 02.01.2026.
//

import UIKit

final class CodeViewController: UIViewController {
    
    private enum Constants {
        static let alphaStart: CGFloat = 0
        static let alphaEnd: CGFloat = 1
        static let errorLabelFontSize: CGFloat = 18
        static let errorLabelTop: CGFloat = 10
        static let errorDuration: TimeInterval = 0.5
        static let errorMessageDuration: TimeInterval = 2
        static let numberOfLines: Int = 2
        static let extraKeyboardIndent: CGFloat = 40
        static let resendButtonHeight: CGFloat = 48
        static let resendButtonWidth: CGFloat = 230
        static let resendButtonBigWidth: CGFloat = 280
        static let resendButtonShortCount: Int = 11
    }

    let interactor: CodeBusinessLogic
    private let cardsLogoView: UIImageView = UIImageView(image: UIImage(named: "logo"))
    private var inputDescriptionText: String = ""
    private var countdownTimer: Timer?
    private var timeLabelText: String = "Отправить код повторно через"
    
    private var remainingTime: TimeInterval = 0
    private let bigLabel: UILabel = UILabel()
    private var smallLabel: UILabel = UILabel()
    private var digitsStackView: CodeStackView = CodeStackView()
    private var timerLabel: UILabel = UILabel()
    private var resendButton: UIButton = UIButton(type: .system)
    
    let timerDuration: TimeInterval = 90.0
    
    init(interactor: CodeBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func hideResendButton() {
        resendButton.isHidden = true
        timerLabel.isHidden = false
        timerLabel.alpha = 1.0
        timerLabel.text = timeLabelText + "\n\(formatTime(Int(timerDuration)))"
        remainingTime = timerDuration
        startCountdown()
    }
    
    private func vibrateOnError() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        configureBackground()
        configureBigLabel()
        configureDigitsStackView()
        configureSmallLabel()
        configureCardsLogoView()
        configureErrorLabel()
        configureTimerLabel()
        configureResendButton()
    }
    
    private func configureDigitsStackView() {
        view.addSubview(digitsStackView)
        digitsStackView.setHeight(50)
        digitsStackView.pinCenterX(to: view)
        digitsStackView.pinTop(to: bigLabel.bottomAnchor, 20)
        digitsStackView.pinLeft(to: view.leadingAnchor, 40)
        digitsStackView.pinRight(to: view.trailingAnchor, 40)
    }
    
    private func configureCardsLogoView() {
        view.addSubview(cardsLogoView)
        cardsLogoView.contentMode = .scaleAspectFit
        cardsLogoView.pinLeft(to: view.leadingAnchor, 30)
        cardsLogoView.pinRight(to: view.trailingAnchor, 30)
        cardsLogoView.pinTop(to: view.safeAreaLayoutGuide.topAnchor, 15)
        cardsLogoView.pinBottom(to: bigLabel.topAnchor, 15)
    }
    
    private func configureBackground() {
        let background = BackgroundView(with: "background-8")
        view.addSubview(background)
        background.pin(to: view)
        view.sendSubviewToBack(background)
    }
    
    private func configureBigLabel() {
        bigLabel.text = "Введите код"
        bigLabel.textAlignment = .center
        bigLabel.textColor = .white
        bigLabel.font = .systemFont(ofSize: 30 , weight: .bold)
        
        view.addSubview(bigLabel)
        bigLabel.pinCenter(to: view)
    }
    
    private func configureSmallLabel() {
        smallLabel.text = "Мы отправили вам проверочный код. Введите его ниже."
        smallLabel.textAlignment = .center
        smallLabel.textColor = .white
        smallLabel.font = .systemFont(ofSize: 20 , weight: .medium)
        smallLabel.numberOfLines = 0
        
        view.addSubview(smallLabel)
        smallLabel.pinCenterX(to: view)
        smallLabel.pinLeft(to: view.leadingAnchor, 30)
        smallLabel.pinRight(to: view.trailingAnchor, 30)
        smallLabel.pinTop(to: digitsStackView.bottomAnchor, 15)
    }
    
    private func configureErrorLabel() {
        // TODO: configure ErrorLabel
    }

    private func configureTimerLabel() {
        view.addSubview(timerLabel)
        timerLabel.pinCenterX(to: view)
        timerLabel.pinBottom(to: view, 50)
        timerLabel.textAlignment = .center
        timerLabel.textColor = .white
        timerLabel.font = .systemFont(ofSize: 17 , weight: .semibold)
        timerLabel.numberOfLines = 2
        timerLabel.text = timeLabelText + "\n\(formatTime(Int(timerDuration)))"
        remainingTime = timerDuration
        startCountdown()
    }
    
    private func configureResendButton() {
        view.addSubview(resendButton)
        resendButton.setTitle("Отправить повторно", for: .normal)
        resendButton.setTitleColor(Colors.lilicA59FFF, for: .normal)
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        resendButton.backgroundColor = .white.withAlphaComponent(0.5)
        resendButton.layer.cornerRadius = 25
        resendButton.pinCenterX(to: view)
        resendButton.pinBottom(to: view, 50)
        resendButton.setHeight(Constants.resendButtonHeight)
        guard let label = resendButton.titleLabel,
              let text = label.text else {
            return
        }
        // If in title more than 11 chars, make button bigger.
        resendButton.setWidth(text.count > Constants.resendButtonShortCount
                                    ? Constants.resendButtonBigWidth
                                    : Constants.resendButtonWidth)
        resendButton.addTarget(self, action: #selector(resendButtonPressed), for: .touchUpInside)
        resendButton.isHidden = true
    }
    
    private func formatTime(_ totalSeconds: Int) -> String {
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func startCountdown() {
        countdownTimer = Timer(
            timeInterval: 1.0,
            target: self,
            selector: #selector(updateLabel),
            userInfo: nil,
            repeats: true
        )
        RunLoop.main.add(countdownTimer ?? Timer(), forMode: .common)
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        let keyboardHeight = keyboardFrame.height

        // Raise view's elements if the keyboard overlaps the error label.
        // Check the overlap through digits stack view, because usually the error label is hidden.
        if let digitsFrame = digitsStackView.superview?.convert(digitsStackView.frame, to: nil) {
            let bottomY = digitsFrame.maxY
            let screenHeight = UIScreen.main.bounds.height
    
            if bottomY > screenHeight - keyboardHeight {
                let overlap = bottomY - (screenHeight - keyboardHeight)
                self.view.frame.origin.y -= overlap + Constants.extraKeyboardIndent
            }
        }
    }

    @objc
    private func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @objc
    private func updateLabel() {
        remainingTime -= 1
        if remainingTime > 0 {
            timerLabel.text = timeLabelText + "\n\(formatTime(Int(remainingTime)))"
        } else {
            countdownTimer?.invalidate()
            hideLabel()
        }
    }

    @objc
    private func hideLabel() {
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0.0
        }) { _ in
            self.timerLabel.isHidden = true
        }
        resendButton.isHidden = false
    }
    
    @objc
    private func resendButtonPressed() {
        UIView.animate(withDuration: 0.3, animations: {
            self.resendButton.transform = CGAffineTransform(scaleX: 20, y: 30)
            }, completion: { _ in
                UIView.animate(withDuration: 0.3) {
                self.resendButton.transform = CGAffineTransform.identity
            }
        })
        // TODO: resend
        hideResendButton()
        configureTimerLabel()
    }
}
