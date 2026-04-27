import UIKit

/// Режим «Помню / не помню»: мок-сеть, живой pan (сдвиг + поворот, отмена отпусканием), переворот по тапу (tap ждёт, пока pan не провалится).
final class FlashcardStudyViewController: UIViewController, UIGestureRecognizerDelegate {

    private let deck: LibraryModels.DeckSet
    private let deckTint: UIColor
    private let mockSession: FlashcardStudyMockSession

    private let backButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    private let centerProgressLabel = UILabel()
    private let pillsRow = UIStackView()
    private let reviewPill = UILabel()
    private let knownPill = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)

    private let cardView = UIView()
    private let frontLabel = UILabel()
    private let backLabel = UILabel()
    private let listenButton = UIButton(type: .system)
    private let forgetButton = UIButton(type: .system)
    private let rememberButton = UIButton(type: .system)
    private let bottomButtonsRow = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let cardTap = UITapGestureRecognizer()
    private let cardPan = UIPanGestureRecognizer()

    private var currentPayload: FlashcardStudyModels.StudyCardPayload?
    private var isBackVisible = false
    private var isBusy = false
    private var isHorizontalCardDrag = false
    private var reviewCount = 0
    private var knownCount = 0

    private let cardTextPurple = UIColor(red: 0.32, green: 0.22, blue: 0.52, alpha: 1)
    private let forgetRed = UIColor(red: 0.92, green: 0.32, blue: 0.38, alpha: 1)
    private let rememberGreen = UIColor(red: 0.28, green: 0.72, blue: 0.48, alpha: 1)
    private let quizletOrange = UIColor(red: 1.0, green: 0.52, blue: 0.2, alpha: 1)

    private let cardDefaultBorderColor = UIColor.white.withAlphaComponent(0.65).cgColor
    private let cardDefaultBorderWidth: CGFloat = 1.2

    init(deck: LibraryModels.DeckSet) {
        self.deck = deck
        self.deckTint = LibraryModels.FolderPalette.folderColor(colorIndex: deck.colorIndex)
        self.mockSession = FlashcardStudyMockSession(deckId: deck.id, deckTitle: deck.title, deckTotal: deck.total)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureBackground()
        configureTopBar()
        configurePillsAndProgress()
        configureCard()
        configureCardPan()
        configureListen()
        configureBottomButtons()
        configureLoading()
        Task { await bootstrapSession() }
    }

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
        view.sendSubviewToBack(bg)
    }

    private func configureTopBar() {
        styleCircleButton(backButton, symbol: "xmark")
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        styleCircleButton(settingsButton, symbol: "gearshape")
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)

        centerProgressLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        centerProgressLabel.textColor = .white
        centerProgressLabel.textAlignment = .center
        centerProgressLabel.text = "— / —"

        [backButton, settingsButton, centerProgressLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            settingsButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            settingsButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            centerProgressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerProgressLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            centerProgressLabel.leadingAnchor.constraint(greaterThanOrEqualTo: backButton.trailingAnchor, constant: 8),
            centerProgressLabel.trailingAnchor.constraint(lessThanOrEqualTo: settingsButton.leadingAnchor, constant: -8)
        ])
    }

    private func configurePillsAndProgress() {
        pillsRow.axis = .horizontal
        pillsRow.spacing = 14
        pillsRow.alignment = .center
        pillsRow.distribution = .equalSpacing
        pillsRow.translatesAutoresizingMaskIntoConstraints = false

        stylePill(reviewPill, initialText: "0", background: quizletOrange)
        stylePill(knownPill, initialText: "0", background: rememberGreen)

        pillsRow.addArrangedSubview(reviewPill)
        pillsRow.addArrangedSubview(knownPill)

        progressView.trackTintColor = .white.withAlphaComponent(0.35)
        progressView.progressTintColor = deckTint
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(pillsRow)
        view.addSubview(progressView)

        NSLayoutConstraint.activate([
            pillsRow.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            pillsRow.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            progressView.topAnchor.constraint(equalTo: pillsRow.bottomAnchor, constant: 12),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            progressView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    private func stylePill(_ label: UILabel, initialText: String, background: UIColor) {
        label.text = initialText
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = background.withAlphaComponent(0.55)
        label.layer.cornerRadius = 18
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(equalToConstant: 36),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 52)
        ])
    }

    private func styleCircleButton(_ btn: UIButton, symbol: String) {
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        btn.setImage(UIImage(systemName: symbol, withConfiguration: cfg), for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .white.withAlphaComponent(0.22)
        btn.layer.cornerRadius = 20
        btn.clipsToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func configureCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white.withAlphaComponent(0.42)
        cardView.layer.cornerRadius = 24
        cardView.layer.borderWidth = cardDefaultBorderWidth
        cardView.layer.borderColor = cardDefaultBorderColor
        cardView.clipsToBounds = true

        for label in [frontLabel, backLabel] {
            label.font = UIFont.systemFont(ofSize: 26, weight: .bold)
            label.textColor = cardTextPurple
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        backLabel.isHidden = true

        cardView.addSubview(frontLabel)
        cardView.addSubview(backLabel)
        view.addSubview(cardView)

        let cardCenterY = cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -28)
        cardCenterY.priority = UILayoutPriority(250)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),
            cardView.topAnchor.constraint(greaterThanOrEqualTo: progressView.bottomAnchor, constant: 18),
            cardCenterY,

            frontLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            frontLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            frontLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            frontLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -28),

            backLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 28),
            backLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            backLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            backLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -28)
        ])
    }

    private func configureCardPan() {
        cardTap.addTarget(self, action: #selector(cardTapped))
        cardTap.cancelsTouchesInView = false
        cardPan.addTarget(self, action: #selector(handleCardPan(_:)))
        cardPan.delegate = self
        cardView.addGestureRecognizer(cardTap)
        cardView.addGestureRecognizer(cardPan)
        cardTap.require(toFail: cardPan)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        false
    }

    @objc
    private func handleCardPan(_ g: UIPanGestureRecognizer) {
        guard !isBusy, currentPayload != nil else {
            g.setTranslation(.zero, in: view)
            return
        }

        let t = g.translation(in: view)
        let v = g.velocity(in: view)
        let w = view.bounds.width
        let threshold = w * 0.28
        let velocityTrigger: CGFloat = 550

        switch g.state {
        case .began:
            isHorizontalCardDrag = false

        case .changed:
            if !isHorizontalCardDrag {
                if abs(t.x) > 14, abs(t.x) > abs(t.y) * 1.05 {
                    isHorizontalCardDrag = true
                } else {
                    return
                }
            }
            applyCardDragTransform(translationX: t.x)
            updateCardBorderForDrag(translationX: t.x)

        case .ended, .cancelled:
            defer {
                isHorizontalCardDrag = false
                g.setTranslation(.zero, in: view)
            }

            if isHorizontalCardDrag {
                let commitLeft = t.x < -threshold || v.x < -velocityTrigger
                let commitRight = t.x > threshold || v.x > velocityTrigger

                if commitLeft {
                    finalizeSwipeCommit(choice: .dontRemember, exitSign: -1)
                } else if commitRight {
                    finalizeSwipeCommit(choice: .remember, exitSign: 1)
                } else {
                    UIView.animate(
                        withDuration: 0.45,
                        delay: 0,
                        usingSpringWithDamping: 0.72,
                        initialSpringVelocity: 0.55,
                        options: [.curveEaseOut, .allowUserInteraction]
                    ) {
                        self.cardView.transform = .identity
                        self.resetCardBorder()
                        self.updateLabelColorsForDrag(translationX: 0)
                    }
                }
            }

        default:
            break
        }
    }

    /// Живой сдвиг + лёгкий поворот (как в Quizlet).
    private func applyCardDragTransform(translationX tx: CGFloat) {
        let w = max(view.bounds.width, 1)
        let maxAngle: CGFloat = .pi / 10
        let angle = (tx / w) * maxAngle * 2.8
        var tform = CGAffineTransform.identity
        tform = tform.translatedBy(x: tx, y: 0)
        tform = tform.rotated(by: angle)
        cardView.transform = tform
    }

    private func updateCardBorderForDrag(translationX tx: CGFloat) {
        if tx < -18 {
            cardView.layer.borderColor = quizletOrange.cgColor
            cardView.layer.borderWidth = 2.5
        } else if tx > 18 {
            cardView.layer.borderColor = rememberGreen.cgColor
            cardView.layer.borderWidth = 2.5
        } else {
            resetCardBorder()
        }
        updateLabelColorsForDrag(translationX: tx)
    }

    private func updateLabelColorsForDrag(translationX tx: CGFloat) {
        if tx < -18 {
            frontLabel.textColor = quizletOrange
            backLabel.textColor = quizletOrange
        } else if tx > 18 {
            frontLabel.textColor = rememberGreen
            backLabel.textColor = rememberGreen
        } else {
            frontLabel.textColor = cardTextPurple
            backLabel.textColor = cardTextPurple
        }
    }

    private func resetCardBorder() {
        cardView.layer.borderWidth = cardDefaultBorderWidth
        cardView.layer.borderColor = cardDefaultBorderColor
    }

    private func finalizeSwipeCommit(choice: FlashcardStudyModels.RememberChoice, exitSign: CGFloat) {
        isBusy = true
        setInteractionEnabled(false)
        let w = view.bounds.width
        let extra: CGFloat = w * 0.65
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn, animations: {
            self.applyCardDragTransform(translationX: exitSign * extra)
            self.cardView.alpha = 0.08
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.cardView.transform = .identity
            self.resetCardBorder()
            self.updateLabelColorsForDrag(translationX: 0)
            Task { [weak self] in await self?.handleAnswer(choice) }
        })

        switch choice {
        case .dontRemember:
            reviewCount += 1
            reviewPill.text = "\(reviewCount)"
        case .remember:
            knownCount += 1
            knownPill.text = "\(knownCount)"
        }
    }

    @objc
    private func cardTapped() {
        flipCard()
    }

    private func flipCard() {
        guard !isBusy, currentPayload != nil else { return }
        let willShowBack = !isBackVisible
        let options: UIView.AnimationOptions = willShowBack ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: cardView, duration: 0.38, options: options, animations: {
            self.isBackVisible = willShowBack
            self.frontLabel.isHidden = self.isBackVisible
            self.backLabel.isHidden = !self.isBackVisible
        })
    }

    private func configureListen() {
        var cfg = UIButton.Configuration.plain()
        cfg.image = UIImage(systemName: "speaker.wave.2.fill")
        cfg.title = "слушать"
        cfg.imagePlacement = .top
        cfg.imagePadding = 6
        cfg.baseForegroundColor = UIColor.white.withAlphaComponent(0.85)
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            return out
        }
        listenButton.configuration = cfg
        listenButton.addTarget(self, action: #selector(listenTapped), for: .touchUpInside)
        listenButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listenButton)

        NSLayoutConstraint.activate([
            listenButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20),
            listenButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureBottomButtons() {
        bottomButtonsRow.axis = .horizontal
        bottomButtonsRow.spacing = 14
        bottomButtonsRow.distribution = .fillEqually
        bottomButtonsRow.alignment = .fill
        bottomButtonsRow.translatesAutoresizingMaskIntoConstraints = false

        styleChoiceButton(forgetButton, title: "не помню", symbol: "xmark", tint: forgetRed)
        styleChoiceButton(rememberButton, title: "помню", symbol: "checkmark", tint: rememberGreen)
        forgetButton.addTarget(self, action: #selector(forgetTapped), for: .touchUpInside)
        rememberButton.addTarget(self, action: #selector(rememberTapped), for: .touchUpInside)

        bottomButtonsRow.addArrangedSubview(forgetButton)
        bottomButtonsRow.addArrangedSubview(rememberButton)

        view.addSubview(bottomButtonsRow)
        NSLayoutConstraint.activate([
            bottomButtonsRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bottomButtonsRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomButtonsRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -88),
            forgetButton.heightAnchor.constraint(equalToConstant: 96),
            rememberButton.heightAnchor.constraint(equalToConstant: 96)
        ])
    }

    private func styleChoiceButton(_ btn: UIButton, title: String, symbol: String, tint: UIColor) {
        var cfg = UIButton.Configuration.filled()
        cfg.cornerStyle = .large
        cfg.baseBackgroundColor = tint
        cfg.baseForegroundColor = .white
        let sym = UIImage.SymbolConfiguration(pointSize: 22, weight: .bold)
        cfg.image = UIImage(systemName: "\(symbol).circle.fill", withConfiguration: sym)
        cfg.title = title
        cfg.imagePlacement = .top
        cfg.imagePadding = 8
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return out
        }
        btn.configuration = cfg
    }

    private func configureLoading() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: cardView.centerYAnchor)
        ])
    }

    @objc
    private func forgetTapped() {
        bumpCounters(for: .dontRemember)
        commitAnswer(.dontRemember, exitSign: -1)
    }

    @objc
    private func rememberTapped() {
        bumpCounters(for: .remember)
        commitAnswer(.remember, exitSign: 1)
    }

    private func bumpCounters(for choice: FlashcardStudyModels.RememberChoice) {
        switch choice {
        case .dontRemember:
            reviewCount += 1
            reviewPill.text = "\(reviewCount)"
        case .remember:
            knownCount += 1
            knownPill.text = "\(knownCount)"
        }
    }

    @objc
    private func listenTapped() {
        let a = UIAlertController(
            title: nil,
            message: "Озвучивание карточек появится позже.\nНабор: «\(deck.title)»",
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc
    private func settingsTapped() {
        let a = UIAlertController(title: nil, message: "Настройки режима повторения появятся позже.", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc
    private func backTapped() {
        let a = UIAlertController(
            title: "Завершить?",
            message: "Прогресс этой сессии будет остановлен.",
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        a.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(a, animated: true)
    }

    private func bootstrapSession() async {
        await MainActor.run { loadingIndicator.startAnimating(); setInteractionEnabled(false) }
        do {
            let card = try await mockSession.fetchInitialCard()
            await MainActor.run {
                applyPayload(card)
                cardView.alpha = 0
                loadingIndicator.stopAnimating()
                UIView.animate(withDuration: 0.28) {
                    self.cardView.alpha = 1
                }
                setInteractionEnabled(true)
            }
        } catch {
            await MainActor.run {
                loadingIndicator.stopAnimating()
                setInteractionEnabled(true)
                let a = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in self?.dismiss(animated: true) })
                present(a, animated: true)
            }
        }
    }

    private func applyPayload(_ payload: FlashcardStudyModels.StudyCardPayload) {
        currentPayload = payload
        isBackVisible = false
        frontLabel.isHidden = false
        backLabel.isHidden = true
        frontLabel.text = payload.front
        backLabel.text = payload.back
        frontLabel.textColor = cardTextPurple
        backLabel.textColor = cardTextPurple
        centerProgressLabel.text = "\(payload.position) / \(payload.total)"
        let p = Float(payload.position) / Float(max(payload.total, 1))
        progressView.setProgress(p, animated: true)
        cardView.transform = .identity
        resetCardBorder()
    }

    private func commitAnswer(_ choice: FlashcardStudyModels.RememberChoice, exitSign: CGFloat) {
        guard !isBusy, currentPayload != nil else { return }
        isBusy = true
        setInteractionEnabled(false)
        let w = view.bounds.width
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseIn, animations: {
            self.applyCardDragTransform(translationX: exitSign * (w * 0.55))
            self.cardView.alpha = 0.15
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.cardView.transform = .identity
            self.resetCardBorder()
            self.updateLabelColorsForDrag(translationX: 0)
            Task { [weak self] in await self?.handleAnswer(choice) }
        })
    }

    private func handleAnswer(_ choice: FlashcardStudyModels.RememberChoice) async {
        do {
            let result = try await mockSession.submitAnswer(choice)
            await MainActor.run {
                switch result {
                case .card(let next):
                    self.cardView.transform = .identity
                    self.cardView.alpha = 0
                    self.applyPayload(next)
                    UIView.animate(
                        withDuration: 0.32,
                        delay: 0,
                        usingSpringWithDamping: 0.88,
                        initialSpringVelocity: 0.4,
                        options: [.curveEaseOut],
                        animations: { self.cardView.alpha = 1 },
                        completion: { _ in
                            self.isBusy = false
                            self.setInteractionEnabled(true)
                        }
                    )
                case .finished(let message):
                    self.isBusy = false
                    self.setInteractionEnabled(true)
                    self.showFinished(message)
                }
            }
        } catch {
            await MainActor.run {
                self.cardView.transform = .identity
                self.cardView.alpha = 1
                self.isBusy = false
                self.setInteractionEnabled(true)
                let a = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(a, animated: true)
            }
        }
    }

    private func showFinished(_ message: String) {
        let a = UIAlertController(title: "Готово", message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(a, animated: true)
    }

    private func setInteractionEnabled(_ on: Bool) {
        forgetButton.isEnabled = on
        rememberButton.isEnabled = on
        listenButton.isEnabled = on
        backButton.isEnabled = on
        settingsButton.isEnabled = on
        cardView.isUserInteractionEnabled = on
        cardTap.isEnabled = on
        cardPan.isEnabled = on
        forgetButton.alpha = on ? 1 : 0.45
        rememberButton.alpha = on ? 1 : 0.45
    }
}
