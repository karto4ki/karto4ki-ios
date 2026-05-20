import UIKit

/// Режим «Помню / не помню»: буфер из двух карточек (верх + следующая под ней), живой pan, тап ждёт pan.
final class FlashcardStudyViewController: UIViewController, UIGestureRecognizerDelegate {

    private let deck: LibraryModels.DeckSet
    private let deckTint: UIColor
    private let realSession: FlashcardStudyRealSession

    private let backButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    private let centerProgressLabel = UILabel()
    private let pillsRow = UIStackView()
    private let reviewPill = UILabel()
    private let knownPill = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)

    private let deckSlot = UIView()
    /// Два слота колоды: роли меняются после свайпа (`topCard` / `bottomCard`). Не `!` + `[a,b]` из IUO — тип массива станет `[DeckCardSurface?]`.
    /// Кто сейчас сверху (жесты, свайп).
    private var topCard: DeckCardSurface?
    /// Кто под верхней (колода); без данных скрыт.
    private var bottomCard: DeckCardSurface?

    private let listenButton = UIButton(type: .system)
    private let forgetButton = UIButton(type: .system)
    private let rememberButton = UIButton(type: .system)
    private let bottomButtonsRow = UIStackView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private let cardTap = UITapGestureRecognizer()
    private let cardPan = UIPanGestureRecognizer()

    private var currentPayload: FlashcardStudyModels.StudyCardPayload?
    private var isBusy = false
    private var isHorizontalCardDrag = false
    /// Сколько карточек отмечено «помню» в текущей сессии (локальный счётчик, синхронизируется с сервером).
    private var localRememberedCount = 0
    /// Общее количество карточек сессии (устанавливается при bootstrap).
    private var totalCards = 0

    private let cardTextPurple = UIColor(red: 0.32, green: 0.22, blue: 0.52, alpha: 1)
    private let forgetRed = UIColor(red: 0.92, green: 0.32, blue: 0.38, alpha: 1)
    private let rememberGreen = UIColor(red: 0.28, green: 0.72, blue: 0.48, alpha: 1)
    private let quizletOrange = UIColor(red: 1.0, green: 0.52, blue: 0.2, alpha: 1)

    private let cardDefaultBorderColor = UIColor.white.withAlphaComponent(0.65).cgColor
    private let cardDefaultBorderWidth: CGFloat = 1.2

    init(deck: LibraryModels.DeckSet, cardService: CardServiceProtocol) {
        self.deck = deck
        self.deckTint = LibraryModels.FolderPalette.folderColor(colorIndex: deck.colorIndex)
        self.realSession = FlashcardStudyRealSession(cardService: cardService, setId: deck.id.uuidString)
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
        configureDeckSlot()
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

        stylePill(reviewPill, initialText: "—", background: quizletOrange)   // осталось выучить
        stylePill(knownPill,  initialText: "0", background: rememberGreen)  // уже помню

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

    private func configureDeckSlot() {
        let a = DeckCardSurface(textPurple: cardTextPurple)
        let b = DeckCardSurface(textPurple: cardTextPurple)
        topCard = a
        bottomCard = b

        deckSlot.translatesAutoresizingMaskIntoConstraints = false
        deckSlot.backgroundColor = .clear
        view.addSubview(deckSlot)

        for s in [a, b] {
            s.translatesAutoresizingMaskIntoConstraints = false
            deckSlot.addSubview(s)
            NSLayoutConstraint.activate([
                s.topAnchor.constraint(equalTo: deckSlot.topAnchor),
                s.leadingAnchor.constraint(equalTo: deckSlot.leadingAnchor),
                s.trailingAnchor.constraint(equalTo: deckSlot.trailingAnchor),
                s.bottomAnchor.constraint(equalTo: deckSlot.bottomAnchor)
            ])
        }
        deckSlot.insertSubview(b, belowSubview: a)

        let cardCenterY = deckSlot.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -28)
        cardCenterY.priority = UILayoutPriority(250)

        NSLayoutConstraint.activate([
            deckSlot.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            deckSlot.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            deckSlot.heightAnchor.constraint(greaterThanOrEqualToConstant: 220),
            deckSlot.topAnchor.constraint(greaterThanOrEqualTo: progressView.bottomAnchor, constant: 18),
            cardCenterY
        ])
    }

    private func configureCardPan() {
        cardTap.addTarget(self, action: #selector(cardTapped))
        cardTap.cancelsTouchesInView = false
        cardPan.addTarget(self, action: #selector(handleCardPan(_:)))
        cardPan.delegate = self
        attachGesturesToTopCard()
    }

    private func attachGesturesToTopCard() {
        guard let top = topCard else { return }
        cardTap.view?.removeGestureRecognizer(cardTap)
        cardPan.view?.removeGestureRecognizer(cardPan)
        top.addGestureRecognizer(cardTap)
        top.addGestureRecognizer(cardPan)
        cardTap.require(toFail: cardPan)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer) -> Bool {
        false
    }

    @objc
    private func handleCardPan(_ g: UIPanGestureRecognizer) {
        guard let top = topCard, g.view === top else { return }
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
                        self.topCard?.transform = .identity
                        self.resetCardBorder()
                    }
                }
            }

        default:
            break
        }
    }

    private func applyCardDragTransform(translationX tx: CGFloat) {
        guard let top = topCard else { return }
        let w = max(view.bounds.width, 1)
        let maxAngle: CGFloat = .pi / 10
        let angle = (tx / w) * maxAngle * 2.8
        var tform = CGAffineTransform.identity
        tform = tform.translatedBy(x: tx, y: 0)
        tform = tform.rotated(by: angle)
        top.transform = tform
    }

    private func updateCardBorderForDrag(translationX tx: CGFloat) {
        guard let top = topCard else { return }
        top.updateDragVisual(
            translationX: tx,
            orange: quizletOrange,
            green: rememberGreen,
            defaultBorder: UIColor(cgColor: cardDefaultBorderColor),
            defaultWidth: cardDefaultBorderWidth
        )
    }

    private func resetCardBorder() {
        topCard?.resetBorder(defaultBorder: UIColor(cgColor: cardDefaultBorderColor), width: cardDefaultBorderWidth)
    }

    private func finalizeSwipeCommit(choice: FlashcardStudyModels.RememberChoice, exitSign: CGFloat) {
        isBusy = true
        setInteractionEnabled(false)
        let w = view.bounds.width
        let extra: CGFloat = w * 0.65
        UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.applyCardDragTransform(translationX: exitSign * extra)
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.resetCardBorder()
            self.afterSwipeFlyOff(choice: choice)
        })

        bumpCounters(for: choice)
    }

    @objc
    private func cardTapped() {
        flipCard()
    }

    private func flipCard() {
        guard !isBusy, currentPayload != nil, let top = topCard else { return }
        top.flip()
    }

    private func configureListen() {
        var cfg = UIButton.Configuration.plain()
        cfg.image = UIImage(systemName: "speaker.wave.2.fill")
        cfg.title = L10n.Study.listen
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
            listenButton.topAnchor.constraint(equalTo: deckSlot.bottomAnchor, constant: 20),
            listenButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func configureBottomButtons() {
        bottomButtonsRow.axis = .horizontal
        bottomButtonsRow.spacing = 14
        bottomButtonsRow.distribution = .fillEqually
        bottomButtonsRow.alignment = .fill
        bottomButtonsRow.translatesAutoresizingMaskIntoConstraints = false

        styleChoiceButton(forgetButton, title: L10n.Study.dontRemember, symbol: "xmark", tint: forgetRed)
        styleChoiceButton(rememberButton, title: L10n.Study.remember, symbol: "checkmark", tint: rememberGreen)
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
            loadingIndicator.centerXAnchor.constraint(equalTo: deckSlot.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: deckSlot.centerYAnchor)
        ])
    }

    @objc
    private func forgetTapped() {
        bumpCounters(for: .dontRemember)
        commitAnswerWithFlyOff(.dontRemember, exitSign: -1)
    }

    @objc
    private func rememberTapped() {
        bumpCounters(for: .remember)
        commitAnswerWithFlyOff(.remember, exitSign: 1)
    }

    private func bumpCounters(for choice: FlashcardStudyModels.RememberChoice) {
        if choice == .remember {
            localRememberedCount += 1
        }
        refreshProgressUI()
    }

    @objc
    private func listenTapped() {
        let a = UIAlertController(
            title: nil,
            message: L10n.Study.ttsComingSoon(deck.title),
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
        present(a, animated: true)
    }

    @objc
    private func settingsTapped() {
        let a = UIAlertController(title: nil, message: L10n.Study.settingsComingSoon, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
        present(a, animated: true)
    }

    @objc
    private func backTapped() {
        dismiss(animated: true)
    }

    private func bootstrapSession() async {
        await MainActor.run { loadingIndicator.startAnimating(); setInteractionEnabled(false) }
        do {
            let boot = try await realSession.bootstrapDeck()
            await MainActor.run {
                self.applyBootstrap(boot)
                self.deckSlot.alpha = 0
                self.loadingIndicator.stopAnimating()
                UIView.animate(withDuration: 0.28) {
                    self.deckSlot.alpha = 1
                }
                self.setInteractionEnabled(true)
            }
        } catch {
            await MainActor.run {
                loadingIndicator.stopAnimating()
                setInteractionEnabled(true)
                let a = UIAlertController(title: L10n.Common.error, message: error.localizedDescription, preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in self?.dismiss(animated: true) })
                present(a, animated: true)
            }
        }
    }

    private func applyBootstrap(_ boot: FlashcardStudyModels.DeckBootstrap) {
        guard let top = topCard, let bottom = bottomCard else { return }
        let border = UIColor(cgColor: cardDefaultBorderColor)
        top.configure(payload: boot.top, defaultBorder: border, borderWidth: cardDefaultBorderWidth)
        currentPayload = boot.top
        top.resetFlipState()
        top.resetToIdentity()
        top.isHidden = false

        if let u = boot.under {
            bottom.configure(payload: u, defaultBorder: border, borderWidth: cardDefaultBorderWidth)
            bottom.resetFlipState()
            bottom.applyDeckPose()
            bottom.isHidden = false
        } else {
            bottom.isHidden = true
        }

        syncProgress(from: boot.top)
        deckSlot.insertSubview(bottom, belowSubview: top)
        attachGesturesToTopCard()
    }

    /// Обновляет пилюли, прогресс-бар и центральный лейбл по локальным счётчикам.
    private func refreshProgressUI(animated: Bool = true) {
        guard totalCards > 0 else { return }
        let remaining = totalCards - localRememberedCount
        reviewPill.text = "\(remaining)"
        knownPill.text  = "\(localRememberedCount)"
        centerProgressLabel.text = "\(localRememberedCount) / \(totalCards)"
        let p = Float(localRememberedCount) / Float(totalCards)
        progressView.setProgress(p, animated: animated)
    }

    /// Синхронизирует локальные счётчики с данными из payload (вызывается при bootstrap и при promote).
    private func syncProgress(from payload: FlashcardStudyModels.StudyCardPayload) {
        totalCards = payload.total
        localRememberedCount = payload.rememberedCount
        refreshProgressUI(animated: false)
    }

    /// Финальный прогресс 100% при завершении сессии.
    private func completeProgressUI() {
        localRememberedCount = totalCards
        refreshProgressUI(animated: false)
    }

    private func commitAnswerWithFlyOff(_ choice: FlashcardStudyModels.RememberChoice, exitSign: CGFloat) {
        guard !isBusy, currentPayload != nil else { return }
        isBusy = true
        setInteractionEnabled(false)
        let w = view.bounds.width
        UIView.animate(withDuration: 0.32, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.applyCardDragTransform(translationX: exitSign * (w * 0.55))
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.resetCardBorder()
            self.afterSwipeFlyOff(choice: choice)
        })
    }

    /// После уезда верхней: не возвращаем её на экран. Если под ней уже есть карта — сразу плавно поднимаем; ответ сервера только подставляет текст в нижний слот без анимации.
    private func afterSwipeFlyOff(choice: FlashcardStudyModels.RememberChoice) {
        guard let oldTop = topCard, let rising = bottomCard else {
            Task { await handleAnswerAfterSwipeServerFirst(choice: choice) }
            return
        }

        oldTop.resetBorder(defaultBorder: UIColor(cgColor: cardDefaultBorderColor), width: cardDefaultBorderWidth)
        oldTop.isHidden = true
        oldTop.resetToIdentity()
        oldTop.alpha = 1

        let canPromoteLocally = !rising.isHidden && rising.payload != nil

        if canPromoteLocally {
            rising.resetFlipState()
            rising.resetBorder(defaultBorder: UIColor(cgColor: cardDefaultBorderColor), width: cardDefaultBorderWidth)
            currentPayload = rising.payload

            UIView.animate(withDuration: 0.36, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
                rising.resetToIdentity()
            }

            topCard = rising
            bottomCard = oldTop
            oldTop.isHidden = true

            deckSlot.insertSubview(oldTop, belowSubview: rising)
            if let pl = rising.payload {
                syncProgress(from: pl)
            }
            attachGesturesToTopCard()
            isBusy = false
            setInteractionEnabled(true)

            Task { await submitAnswerAndApplyPrefetchOnly(choice: choice) }
        } else {
            Task { await handleAnswerAfterSwipeServerFirst(choice: choice) }
        }
    }

    private func submitAnswerAndApplyPrefetchOnly(choice: FlashcardStudyModels.RememberChoice) async {
        do {
            let result = try await realSession.submitDeckAnswer(choice)
            await MainActor.run {
                switch result {
                case .continued(_, let prefetchedUnder):
                    // newTop уже на экране (был в нижнем слоте, уже промоутирован) — используем только prefetch
                    self.applyPrefetchToBottomCard(prefetchedUnder)
                    // Синхронизируем счётчик с сервером на случай расхождения
                    if let p = prefetchedUnder { self.syncProgress(from: p) }
                case .finished(let message):
                    self.completeProgressUI()
                    self.topCard?.isHidden = true
                    self.bottomCard?.isHidden = true
                    self.showFinished(message)
                }
            }
        } catch {
            await MainActor.run {
                let a = UIAlertController(title: L10n.Common.error, message: error.localizedDescription, preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(a, animated: true)
            }
        }
    }

    /// «Server-first» путь: нижний слот был пустым — ждём сервер, потом конфигурируем новую верхнюю карточку.
    private func handleAnswerAfterSwipeServerFirst(choice: FlashcardStudyModels.RememberChoice) async {
        do {
            let result = try await realSession.submitDeckAnswer(choice)
            await MainActor.run {
                switch result {
                case .continued(let newTop, let prefetchedUnder):
                    self.promoteDeckAfterServer(newTop: newTop, prefetchedUnder: prefetchedUnder)
                case .finished(let message):
                    self.completeProgressUI()
                    self.topCard?.isHidden = true
                    self.bottomCard?.isHidden = true
                    self.showFinished(message)
                }
            }
        } catch {
            await MainActor.run {
                self.topCard?.isHidden = false
                self.topCard?.alpha = 1
                self.topCard?.transform = .identity
                self.isBusy = false
                self.setInteractionEnabled(true)
                let a = UIAlertController(title: L10n.Common.error, message: error.localizedDescription, preferredStyle: .alert)
                a.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(a, animated: true)
            }
            return
        }
        await MainActor.run {
            self.isBusy = false
            self.setInteractionEnabled(true)
        }
    }

    private func applyPrefetchToBottomCard(_ prefetchedUnder: FlashcardStudyModels.StudyCardPayload?) {
        guard let bottom = bottomCard else { return }
        let border = UIColor(cgColor: cardDefaultBorderColor)
        if let p = prefetchedUnder {
            UIView.performWithoutAnimation {
                bottom.configure(payload: p, defaultBorder: border, borderWidth: cardDefaultBorderWidth)
                bottom.applyDeckPose()
                bottom.isHidden = false
            }
        } else {
            UIView.performWithoutAnimation {
                bottom.isHidden = true
            }
        }
    }

    /// «Server-first» promote: конфигурируем новую верхнюю карточку данными от сервера,
    /// затем подгружаем prefetch в нижний слот.
    private func promoteDeckAfterServer(newTop: FlashcardStudyModels.StudyCardPayload,
                                        prefetchedUnder: FlashcardStudyModels.StudyCardPayload?) {
        guard let oldTop = topCard, let rising = bottomCard else { return }

        oldTop.isHidden = true
        oldTop.resetToIdentity()
        oldTop.resetFlipState()

        let border = UIColor(cgColor: cardDefaultBorderColor)

        // rising (нижний слот) был пустым — конфигурируем его данными новой верхней карточки
        UIView.performWithoutAnimation {
            rising.configure(payload: newTop, defaultBorder: border, borderWidth: cardDefaultBorderWidth)
            rising.resetFlipState()
            rising.applyDeckPose()   // начальная поза для анимации подъёма
            rising.isHidden = false  // был скрыт — теперь показываем
        }
        currentPayload = newTop

        UIView.animate(withDuration: 0.36, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            rising.resetToIdentity()
        }

        if let p = prefetchedUnder {
            UIView.performWithoutAnimation {
                oldTop.configure(payload: p, defaultBorder: border, borderWidth: cardDefaultBorderWidth)
                oldTop.resetFlipState()
                oldTop.applyDeckPose()
                oldTop.isHidden = false
            }
        } else {
            UIView.performWithoutAnimation {
                oldTop.isHidden = true
            }
        }

        topCard = rising
        bottomCard = oldTop

        deckSlot.insertSubview(oldTop, belowSubview: rising)
        syncProgress(from: newTop)
        attachGesturesToTopCard()
    }

    private func showFinished(_ message: String) {
        let a = UIAlertController(title: L10n.Common.done, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: L10n.Common.ok, style: .default) { [weak self] _ in
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
        deckSlot.isUserInteractionEnabled = on
        cardTap.isEnabled = on
        cardPan.isEnabled = on
        forgetButton.alpha = on ? 1 : 0.45
        rememberButton.alpha = on ? 1 : 0.45
    }
}

// MARK: - Одна карточка (лице / рубашка)

private final class DeckCardSurface: UIView {

    private let frontLabel = UILabel()
    private let backLabel = UILabel()
    private(set) var payload: FlashcardStudyModels.StudyCardPayload?
    private var isBackVisible = false
    private let textPurple: UIColor

    init(textPurple: UIColor) {
        self.textPurple = textPurple
        super.init(frame: .zero)
        backgroundColor = UIColor(red: 0.82, green: 0.86, blue: 0.97, alpha: 1.00)
        layer.cornerRadius = 24
        layer.borderWidth = 1.2
        layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        clipsToBounds = true

        for lb in [frontLabel, backLabel] {
            lb.font = UIFont.systemFont(ofSize: 26, weight: .bold)
            lb.textColor = textPurple
            lb.textAlignment = .center
            lb.numberOfLines = 0
            lb.translatesAutoresizingMaskIntoConstraints = false
        }
        backLabel.isHidden = true
        addSubview(frontLabel)
        addSubview(backLabel)
        NSLayoutConstraint.activate([
            frontLabel.topAnchor.constraint(equalTo: topAnchor, constant: 28),
            frontLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            frontLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            frontLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28),
            backLabel.topAnchor.constraint(equalTo: topAnchor, constant: 28),
            backLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            backLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            backLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -28)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(payload: FlashcardStudyModels.StudyCardPayload, defaultBorder: UIColor, borderWidth: CGFloat) {
        self.payload = payload
        frontLabel.text = payload.front
        backLabel.text = payload.back
        resetFlipState()
        layer.borderWidth = borderWidth
        layer.borderColor = defaultBorder.cgColor
        frontLabel.textColor = textPurple
        backLabel.textColor = textPurple
    }

    func resetFlipState() {
        isBackVisible = false
        frontLabel.isHidden = false
        backLabel.isHidden = true
    }

    func applyDeckPose() {
        transform = CGAffineTransform(translationX: 0, y: 12).scaledBy(x: 0.94, y: 0.94)
        alpha = 1
    }

    func resetToIdentity() {
        transform = .identity
    }

    func updateDragVisual(translationX tx: CGFloat, orange: UIColor, green: UIColor, defaultBorder: UIColor, defaultWidth: CGFloat) {
        if tx < -18 {
            layer.borderColor = orange.cgColor
            layer.borderWidth = 2.5
            frontLabel.textColor = orange
            backLabel.textColor = orange
        } else if tx > 18 {
            layer.borderColor = green.cgColor
            layer.borderWidth = 2.5
            frontLabel.textColor = green
            backLabel.textColor = green
        } else {
            layer.borderWidth = defaultWidth
            layer.borderColor = defaultBorder.cgColor
            frontLabel.textColor = textPurple
            backLabel.textColor = textPurple
        }
    }

    func resetBorder(defaultBorder: UIColor, width: CGFloat) {
        layer.borderWidth = width
        layer.borderColor = defaultBorder.cgColor
        frontLabel.textColor = textPurple
        backLabel.textColor = textPurple
    }

    func flip() {
        guard payload != nil else { return }
        let willShowBack = !isBackVisible
        let options: UIView.AnimationOptions = willShowBack ? .transitionFlipFromRight : .transitionFlipFromLeft
        UIView.transition(with: self, duration: 0.38, options: options, animations: {
            self.isBackVisible = willShowBack
            self.frontLabel.isHidden = self.isBackVisible
            self.backLabel.isHidden = !self.isBackVisible
        })
    }
}
