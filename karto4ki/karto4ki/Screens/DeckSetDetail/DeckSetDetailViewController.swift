import UIKit

final class DeckSetDetailViewController: UIViewController, UIGestureRecognizerDelegate {

    private let deck: LibraryModels.DeckSet
    private let cardService: CardServiceProtocol
    private let deckFolderTint: UIColor

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let backButton = UIButton(type: .system)
    private let editButton = UIButton(type: .system)

    private let folderIcon = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let authorLabel = UILabel()
    private let createdLabel = UILabel()

    private let statsContainer = UIView()
    private let statsStack = UIStackView()

    private let studyActionsStack = UIStackView()
    private let rememberNotRememberButton = UIButton(type: .system)
    private let quizButton = UIButton(type: .system)
    private let addToLibraryButton = UIButton(type: .system)
    private let cardsSectionTitle = UILabel()
    private let cardsStack = UIStackView()
    private let addCardButton = UIButton(type: .system)
    private let outsideTap = UITapGestureRecognizer()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    private var flashcards: [DeckSetDetailModels.FlashcardRow] = []
    private var answerHiddenById: [UUID: Bool] = [:]
    private var isEditingCards = false
    private var studyButtonsEnabled = false
    private var hasAppearedOnce = false

    // Лейблы-значения в блоке статистики — обновляются при изменении кол-ва карточек
    private let statLearnedLabel  = UILabel()
    private let statUnlearnedLabel = UILabel()
    private let statTotalLabel    = UILabel()
    private let statPctLabel      = UILabel()

    private let profilePurple = UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
    private let glassCorner: CGFloat = 22

    init(deck: LibraryModels.DeckSet, cardService: CardServiceProtocol) {
        self.deck = deck
        self.cardService = cardService
        self.deckFolderTint = LibraryModels.FolderPalette.folderColor(colorIndex: deck.colorIndex)
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
        configureScroll()
        configureOutsideTap()
        configureTopBar()
        configureHeader()
        configureStats()
        configureStudyEntryButtons()
        configureAddToLibrary()
        configureCardsSection()
        configureAddCard()
        configureLoading()

        loadCards()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hasAppearedOnce {
            // Повторное появление (например, возврат из режима изучения) — обновляем карточки и статистику
            loadCards()
        } else {
            hasAppearedOnce = true
        }
    }

    // MARK: - Background & Layout

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
        view.sendSubviewToBack(bg)
    }

    private func configureScroll() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        scrollView.backgroundColor = .clear
        scrollView.contentInset.bottom = 92
        scrollView.verticalScrollIndicatorInsets.bottom = 92
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func configureOutsideTap() {
        outsideTap.addTarget(self, action: #selector(handleOutsideTap))
        outsideTap.cancelsTouchesInView = false
        outsideTap.delegate = self
        scrollView.addGestureRecognizer(outsideTap)
    }

    private func configureLoading() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // MARK: - Top bar

    private func configureTopBar() {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        styleCircleButton(backButton, symbol: "chevron.left")
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        styleCircleButton(editButton, symbol: "pencil")
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        editButton.isHidden = !deck.isUserOwned
        updateEditButtonIcon()

        row.addSubview(backButton)
        row.addSubview(editButton)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            backButton.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            backButton.topAnchor.constraint(equalTo: row.topAnchor),
            backButton.bottomAnchor.constraint(equalTo: row.bottomAnchor),

            editButton.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            editButton.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])

        contentStack.addArrangedSubview(row)
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

    // MARK: - Header

    private func configureHeader() {
        folderIcon.image = UIImage(systemName: "rectangle.on.rectangle.angled")
        folderIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 36, weight: .semibold)
        folderIcon.tintColor = deckFolderTint
        folderIcon.contentMode = .scaleAspectFit
        folderIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            folderIcon.widthAnchor.constraint(equalToConstant: 52),
            folderIcon.heightAnchor.constraint(equalToConstant: 52)
        ])

        let (main, sub) = Self.splitDeckTitle(deck.title)
        titleLabel.text = main
        titleLabel.font = Fonts.futuraB22
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        subtitleLabel.text = sub
        subtitleLabel.isHidden = sub.isEmpty
        subtitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.88)
        subtitleLabel.numberOfLines = 0

        let authorName = deck.isUserOwned ? L10n.DeckDetail.authorYou : (deck.authorName ?? L10n.DeckDetail.authorCommunity)
        authorLabel.text = L10n.Common.author(authorName)
        authorLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        authorLabel.textColor = UIColor.white.withAlphaComponent(0.78)

        let df = DateFormatter()
        df.locale = Locale.current
        df.dateFormat = "dd.MM.yyyy"
        createdLabel.text = L10n.Common.created(df.string(from: deck.addedAt))
        createdLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        createdLabel.textColor = UIColor.white.withAlphaComponent(0.78)

        let metaRow = UIStackView(arrangedSubviews: [authorLabel, createdLabel])
        metaRow.axis = .vertical
        metaRow.spacing = 4
        metaRow.alignment = .leading

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, metaRow])
        textStack.axis = .vertical
        textStack.spacing = 6
        textStack.alignment = .leading

        let headerRow = UIStackView(arrangedSubviews: [folderIcon, textStack])
        headerRow.axis = .horizontal
        headerRow.alignment = .top
        headerRow.spacing = 14

        contentStack.addArrangedSubview(headerRow)
    }

    // MARK: - Stats

    private func configureStats() {
        statsContainer.backgroundColor = .white.withAlphaComponent(0.22)
        statsContainer.layer.cornerRadius = glassCorner
        statsContainer.layer.borderWidth = 1
        statsContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        statsContainer.translatesAutoresizingMaskIntoConstraints = false

        statsStack.axis = .vertical
        statsStack.spacing = 10
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        statsStack.addArrangedSubview(statLine(title: L10n.DeckDetail.statLearned,   valueLabel: statLearnedLabel))
        statsStack.addArrangedSubview(statLine(title: L10n.DeckDetail.statUnlearned, valueLabel: statUnlearnedLabel))
        statsStack.addArrangedSubview(statLine(title: L10n.DeckDetail.statTotal,     valueLabel: statTotalLabel))
        statsStack.addArrangedSubview(statLine(title: L10n.DeckDetail.statPct,       valueLabel: statPctLabel))

        statsContainer.addSubview(statsStack)
        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 14),
            statsStack.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -14)
        ])

        contentStack.addArrangedSubview(statsContainer)
        updateStats()
    }

    /// Пересчитывает статистику по текущему массиву flashcards и обновляет лейблы.
    private func updateStats() {
        let total    = flashcards.count
        // Считаем из актуальных статусов карточек, а не из deck.learned (закэшированного при открытии экрана)
        let learned  = flashcards.filter { $0.isLearned }.count
        let unlearned = max(0, total - learned)
        let pct: Int  = total > 0 ? Int(round(Double(learned) / Double(total) * 100)) : 0

        statLearnedLabel.text   = "\(learned)"
        statUnlearnedLabel.text = "\(unlearned)"
        statTotalLabel.text     = "\(total)"
        statPctLabel.text       = "\(pct)%"
    }

    private func statLine(title: String, valueLabel: UILabel) -> UIView {
        let t = UILabel()
        t.text = title
        t.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        t.textColor = UIColor.white.withAlphaComponent(0.8)

        valueLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        valueLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [t, valueLabel])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        return row
    }

    // MARK: - Study buttons

    private func configureStudyEntryButtons() {
        studyActionsStack.axis = .vertical
        studyActionsStack.spacing = 10
        studyActionsStack.alignment = .fill

        rememberNotRememberButton.setTitle(L10n.DeckDetail.studyRemember, for: .normal)
        rememberNotRememberButton.setTitleColor(.white, for: .normal)
        rememberNotRememberButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        rememberNotRememberButton.backgroundColor = deckFolderTint.withAlphaComponent(0.55)
        rememberNotRememberButton.layer.cornerRadius = glassCorner
        rememberNotRememberButton.layer.borderWidth = 1
        rememberNotRememberButton.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        rememberNotRememberButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        rememberNotRememberButton.addTarget(self, action: #selector(rememberNotRememberStudyTapped), for: .touchUpInside)

        quizButton.setTitle(L10n.Quiz.title, for: .normal)
        quizButton.setTitleColor(.white, for: .normal)
        quizButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        quizButton.backgroundColor = .clear
        quizButton.layer.cornerRadius = glassCorner
        quizButton.layer.borderWidth = 1.5
        quizButton.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        quizButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        quizButton.addTarget(self, action: #selector(quizTapped), for: .touchUpInside)

        // Начально неактивны — включатся после загрузки карточек
        setStudyButtonsEnabled(false)

        studyActionsStack.addArrangedSubview(rememberNotRememberButton)
        studyActionsStack.addArrangedSubview(quizButton)
        contentStack.addArrangedSubview(studyActionsStack)
        contentStack.setCustomSpacing(12, after: statsContainer)
    }

    private func setStudyButtonsEnabled(_ enabled: Bool) {
        studyButtonsEnabled = enabled
        rememberNotRememberButton.isEnabled = enabled
        quizButton.isEnabled = enabled
        rememberNotRememberButton.alpha = enabled ? 1 : 0.45
        quizButton.alpha = enabled ? 1 : 0.45
    }

    // MARK: - Add to library

    private func configureAddToLibrary() {
        addToLibraryButton.isHidden = deck.isUserOwned
        addToLibraryButton.setTitle(L10n.DeckDetail.addToLibrary, for: .normal)
        addToLibraryButton.setTitleColor(.white, for: .normal)
        addToLibraryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addToLibraryButton.backgroundColor = profilePurple.withAlphaComponent(0.55)
        addToLibraryButton.layer.cornerRadius = glassCorner
        addToLibraryButton.layer.borderWidth = 1
        addToLibraryButton.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        addToLibraryButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        addToLibraryButton.addTarget(self, action: #selector(addToLibraryTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(addToLibraryButton)
    }

    // MARK: - Cards section

    private func configureCardsSection() {
        cardsSectionTitle.text = L10n.DeckDetail.cards
        cardsSectionTitle.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        cardsSectionTitle.textColor = .white
        contentStack.addArrangedSubview(cardsSectionTitle)

        cardsStack.axis = .vertical
        cardsStack.spacing = 12
        contentStack.addArrangedSubview(cardsStack)

        rebuildCardRows()
    }

    private func rebuildCardRows() {
        cardsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, card) in flashcards.enumerated() {
            let row = DeckSetDetailCardRowView()
            let hidden = answerHiddenById[card.id] ?? false
            row.configure(
                index: i + 1,
                row: card,
                isEditing: isEditingCards,
                answerHidden: hidden,
                accentColor: deckFolderTint
            )
            row.onDeleteTap = { [weak self] in self?.confirmDeleteCard(card) }
            row.onMoreTap = { [weak self] source in
                self?.presentCardMenu(card: card, sourceView: source)
            }
            row.onEyeTap = { [weak self] in self?.toggleAnswerVisibility(cardId: card.id) }
            cardsStack.addArrangedSubview(row)
        }
    }

    private func configureAddCard() {
        guard deck.isUserOwned else { return }

        let plusCfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        addCardButton.setImage(UIImage(systemName: "plus.circle", withConfiguration: plusCfg), for: .normal)
        addCardButton.setTitle(" Добавить карточку", for: .normal)
        addCardButton.tintColor = .white
        addCardButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        addCardButton.backgroundColor = .clear
        addCardButton.layer.cornerRadius = glassCorner
        addCardButton.layer.borderWidth = 1.5
        addCardButton.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        addCardButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        addCardButton.addTarget(self, action: #selector(addCardTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(addCardButton)
    }

    // MARK: - Load cards from API

    private func loadCards() {
        loadingIndicator.startAnimating()
        Task {
            do {
                let response = try await cardService.getCards(setId: deck.id.uuidString.lowercased(), offset: nil, limit: nil)
                let rows = response.cards.map { DeckSetDetailModels.FlashcardRow(from: $0) }
                await MainActor.run {
                    flashcards = rows
                    for c in flashcards { answerHiddenById[c.id] = true }
                    loadingIndicator.stopAnimating()
                    setStudyButtonsEnabled(!flashcards.isEmpty)
                    updateStats()
                    rebuildCardRows()
                }
            } catch {
                await MainActor.run {
                    loadingIndicator.stopAnimating()
                    showError(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Actions

    @objc private func backTapped() {
        // Инвалидируем TTL сетов — библиотека сделает свежий сетевой запрос и покажет актуальные learnedCount
        AppCacheStore.invalidateSets()
        dismiss(animated: true)
    }

    @objc private func editTapped() { setEditingCards(!isEditingCards) }

    private func setEditingCards(_ editing: Bool) {
        isEditingCards = editing
        updateEditButtonIcon()
        rebuildCardRows()
    }

    private func updateEditButtonIcon() {
        let symbol = isEditingCards ? "checkmark" : "pencil"
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        UIView.performWithoutAnimation {
            editButton.setImage(UIImage(systemName: symbol, withConfiguration: cfg), for: .normal)
            editButton.layoutIfNeeded()
        }
    }

    @objc private func handleOutsideTap(_ g: UITapGestureRecognizer) {
        guard isEditingCards else { return }
        let pointInCardsStack = g.location(in: cardsStack)
        let tappedCardRow = cardsStack.arrangedSubviews.contains { row in
            !row.isHidden && row.frame.contains(pointInCardsStack)
        }
        if tappedCardRow { return }
        setEditingCards(false)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === outsideTap else { return true }
        var v: UIView? = touch.view
        while let current = v {
            if current is UIControl { return false }
            v = current.superview
        }
        return true
    }

    @objc private func rememberNotRememberStudyTapped() {
        let study = FlashcardStudyViewController(deck: deck, cardService: cardService)
        study.modalPresentationStyle = .fullScreen
        present(study, animated: true)
    }

    @objc private func quizTapped() {
        guard flashcards.count >= 4 else {
            let a = UIAlertController(title: L10n.Quiz.title, message: L10n.Quiz.tooFewCards, preferredStyle: .alert)
            a.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
            present(a, animated: true)
            return
        }
        quizButton.isEnabled = false
        quizButton.alpha = 0.5
        Task {
            do {
                let session = try await cardService.startQuiz(
                    setId: deck.id.uuidString.lowercased(),
                    questionCount: min(flashcards.count, 20)
                )
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    quizButton.isEnabled = true
                    quizButton.alpha = 1
                    let quizVC = QuizViewController(deck: deck, session: session, cardService: cardService)
                    quizVC.onFinished = { [weak self] in self?.loadCards() }
                    present(quizVC, animated: true)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    quizButton.isEnabled = true
                    quizButton.alpha = 1
                    let a = UIAlertController(
                        title: L10n.Quiz.errorStart,
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    a.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
                    present(a, animated: true)
                }
            }
        }
    }

    // MARK: - Add to library (clone set)

    @objc private func addToLibraryTapped() {
        addToLibraryButton.isEnabled = false
        addToLibraryButton.alpha = 0.6
        Task {
            do {
                _ = try await cardService.cloneSet(setId: deck.id.uuidString.lowercased())
                await MainActor.run {
                    addToLibraryButton.isEnabled = true
                    addToLibraryButton.alpha = 1
                    let a = UIAlertController(
                        title: L10n.DeckDetail.addedTitle,
                        message: L10n.DeckDetail.addedMessage,
                        preferredStyle: .alert
                    )
                    a.addAction(UIAlertAction(title: L10n.Common.ok, style: .default))
                    present(a, animated: true)
                }
            } catch {
                await MainActor.run {
                    addToLibraryButton.isEnabled = true
                    addToLibraryButton.alpha = 1
                    showError(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Add card

    @objc private func addCardTapped() {
        let alert = UIAlertController(title: L10n.DeckDetail.newCard, message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = L10n.DeckDetail.cardFrontPlaceholder
            tf.autocapitalizationType = .sentences
            tf.returnKeyType = .next
        }
        alert.addTextField { tf in
            tf.placeholder = L10n.DeckDetail.cardBackPlaceholder
            tf.autocapitalizationType = .sentences
            tf.returnKeyType = .done
        }
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Common.add, style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let front = alert?.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let back  = alert?.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !front.isEmpty, !back.isEmpty else {
                self.showError(L10n.DeckDetail.fillBothFields)
                return
            }
            self.createCard(front: front, back: back)
        })
        present(alert, animated: true)
    }

    private func createCard(front: String, back: String) {
        Task {
            do {
                let request = CreateCardRequestAPI(front: front, back: back, imageUrl: nil)
                let api = try await cardService.createCard(
                    setId: deck.id.uuidString.lowercased(),
                    request: request,
                    idempotencyKey: UUID().uuidString
                )
                let row = DeckSetDetailModels.FlashcardRow(from: api)
                await MainActor.run {
                    flashcards.append(row)
                    answerHiddenById[row.id] = true
                    setStudyButtonsEnabled(true)
                    updateStats()
                    rebuildCardRows()
                    // Библиотека должна показать обновлённое кол-во карточек
                    AppCacheStore.invalidateSets()
                }
            } catch {
                await MainActor.run { showError(error.localizedDescription) }
            }
        }
    }

    // MARK: - Card menu (edit)

    private func presentCardMenu(card: DeckSetDetailModels.FlashcardRow, sourceView: UIView) {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: L10n.Common.change, style: .default) { [weak self] _ in
            self?.presentEditCard(card)
        })
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = sourceView
            pop.sourceRect = sourceView.bounds
        }
        present(sheet, animated: true)
    }

    private func presentEditCard(_ card: DeckSetDetailModels.FlashcardRow) {
        let alert = UIAlertController(title: L10n.DeckDetail.editCard, message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.text = card.question
            tf.placeholder = L10n.DeckDetail.cardFrontPlaceholder
            tf.autocapitalizationType = .sentences
        }
        alert.addTextField { tf in
            tf.text = card.answer
            tf.placeholder = L10n.DeckDetail.cardBackPlaceholder
            tf.autocapitalizationType = .sentences
        }
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.Common.save, style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let front = alert?.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let back  = alert?.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !front.isEmpty, !back.isEmpty else {
                self.showError(L10n.DeckDetail.fillBothFields)
                return
            }
            self.updateCard(card, front: front, back: back)
        })
        present(alert, animated: true)
    }

    private func updateCard(_ card: DeckSetDetailModels.FlashcardRow, front: String, back: String) {
        Task {
            do {
                let request = UpdateCardRequestAPI(front: front, back: back, imageUrl: nil)
                let api = try await cardService.updateCard(cardId: card.apiId, request: request)
                await MainActor.run {
                    if let idx = flashcards.firstIndex(where: { $0.id == card.id }) {
                        flashcards[idx].question = api.front
                        flashcards[idx].answer = api.back
                    }
                    rebuildCardRows()
                }
            } catch {
                await MainActor.run { showError(error.localizedDescription) }
            }
        }
    }

    // MARK: - Delete card

    private func confirmDeleteCard(_ card: DeckSetDetailModels.FlashcardRow) {
        let a = UIAlertController(title: L10n.DeckDetail.deleteCard, message: card.question, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        a.addAction(UIAlertAction(title: L10n.Common.delete, style: .destructive) { [weak self] _ in
            self?.deleteCard(card)
        })
        present(a, animated: true)
    }

    private func deleteCard(_ card: DeckSetDetailModels.FlashcardRow) {
        // Сразу убираем из UI (оптимистичный update)
        flashcards.removeAll { $0.id == card.id }
        answerHiddenById[card.id] = nil
        setStudyButtonsEnabled(!flashcards.isEmpty)
        updateStats()
        rebuildCardRows()
        AppCacheStore.invalidateSets()

        Task {
            do {
                try await cardService.deleteCard(cardId: card.apiId)
            } catch {
                // Если удаление с сервера не прошло — возвращаем карточку обратно
                await MainActor.run {
                    flashcards.append(card)
                    answerHiddenById[card.id] = true
                    setStudyButtonsEnabled(true)
                    updateStats()
                    rebuildCardRows()
                    AppCacheStore.invalidateSets()
                    showError(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Eye toggle

    private func toggleAnswerVisibility(cardId: UUID) {
        let cur = answerHiddenById[cardId] ?? true
        answerHiddenById[cardId] = !cur
        rebuildCardRows()
    }

    // MARK: - Helpers

    private func showError(_ message: String) {
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    private static func splitDeckTitle(_ raw: String) -> (String, String) {
        let parts = raw.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: true)
            .map { $0.trimmingCharacters(in: .whitespaces) }
        if parts.count == 2 {
            return (parts[0], parts[1])
        }
        return (raw, "")
    }
}
