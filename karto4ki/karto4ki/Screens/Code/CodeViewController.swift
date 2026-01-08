//
//  CodeViewController.swift
//  karto4ki
//
//  Created by лизо4ка курунок on 02.01.2026.
//

import UIKit

final class CodeViewController: UIViewController, UIGestureRecognizerDelegate, KeyboardAvoiding {

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

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private var keyboardInset: CGFloat = 0

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

        configureUI()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        scrollView.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startKeyboardAvoiding()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopKeyboardAvoiding()
    }
    
    func keyboardAdjustment(height: CGFloat,
                            duration: TimeInterval,
                            options: UIView.AnimationOptions) {
        
        keyboardInset = height

        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = self.keyboardInset
            self.scrollView.verticalScrollIndicatorInsets.bottom = self.keyboardInset
            self.view.layoutIfNeeded()
        }

        let rect = digitsStackView.convert(digitsStackView.bounds, to: scrollView).insetBy(dx: 0, dy: -24)
        scrollView.scrollRectToVisible(rect, animated: true)
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

    private func configureUI() {
        configureBackground()
        configureScroll()
        configureBigLabel()
        configureDigitsStackView()
        configureSmallLabel()
        configureCardsLogoView()
        configureTimerLabel()
        configureResendButton()
    }

    private func configureScroll() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.pinTop(to: view.topAnchor)
        scrollView.pinBottom(to: view.bottomAnchor)
        scrollView.pinLeft(to: view.leadingAnchor)
        scrollView.pinRight(to: view.trailingAnchor)
        
        contentView.pinTop(to: scrollView.contentLayoutGuide.topAnchor)
        contentView.pinBottom(to: scrollView.contentLayoutGuide.bottomAnchor)
        contentView.pinLeft(to: scrollView.contentLayoutGuide.leadingAnchor)
        contentView.pinRight(to: scrollView.contentLayoutGuide.trailingAnchor)

        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    private func configureDigitsStackView() {
        contentView.addSubview(digitsStackView)
        digitsStackView.setHeight(50)
        digitsStackView.pinCenterX(to: contentView)
        digitsStackView.pinTop(to: bigLabel.bottomAnchor, 20)
        digitsStackView.pinLeft(to: contentView.leadingAnchor, 40)
        digitsStackView.pinRight(to: contentView.trailingAnchor, 40)
    }

    private func configureCardsLogoView() {
        contentView.addSubview(cardsLogoView)
        cardsLogoView.contentMode = .scaleAspectFit
        cardsLogoView.pinLeft(to: contentView.leadingAnchor, 30)
        cardsLogoView.pinRight(to: contentView.trailingAnchor, 30)
        cardsLogoView.pinTop(to: contentView.safeAreaLayoutGuide.topAnchor, 15)
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
        bigLabel.font = .systemFont(ofSize: 30, weight: .bold)

        contentView.addSubview(bigLabel)
        bigLabel.pinCenterX(to: contentView)
        bigLabel.pinCenterY(to: contentView.centerYAnchor)
    }

    private func configureSmallLabel() {
        smallLabel.text = "Мы отправили вам проверочный код. Введите его ниже."
        smallLabel.textAlignment = .center
        smallLabel.textColor = .white
        smallLabel.font = .systemFont(ofSize: 20, weight: .medium)
        smallLabel.numberOfLines = 0

        contentView.addSubview(smallLabel)
        smallLabel.pinCenterX(to: contentView)
        smallLabel.pinLeft(to: contentView.leadingAnchor, 30)
        smallLabel.pinRight(to: contentView.trailingAnchor, 30)
        smallLabel.pinTop(to: digitsStackView.bottomAnchor, 15)
    }

    private func configureTimerLabel() {
        contentView.addSubview(timerLabel)
        timerLabel.pinCenterX(to: contentView)
        timerLabel.pinBottom(to: contentView.bottomAnchor, 50)
        timerLabel.textAlignment = .center
        timerLabel.textColor = .white
        timerLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        timerLabel.numberOfLines = 2
        timerLabel.text = timeLabelText + "\n\(formatTime(Int(timerDuration)))"
        remainingTime = timerDuration
        startCountdown()
    }

    private func configureResendButton() {
        contentView.addSubview(resendButton)
        resendButton.setTitle("Отправить повторно", for: .normal)
        resendButton.setTitleColor(Colors.lilicA59FFF, for: .normal)
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        resendButton.backgroundColor = .white.withAlphaComponent(0.5)
        resendButton.layer.cornerRadius = 25
        resendButton.pinCenterX(to: contentView)
        resendButton.pinBottom(to: contentView.bottomAnchor, 50)
        resendButton.setHeight(Constants.resendButtonHeight)

        guard let label = resendButton.titleLabel, let text = label.text else { return }
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
        hideResendButton()
        configureTimerLabel()
    }
}
