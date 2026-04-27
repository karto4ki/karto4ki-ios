import UIKit

final class DeckSetDetailViewController: UIViewController {

    private let deck: LibraryModels.DeckSet
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
    private let typeAnswerButton = UIButton(type: .system)
    private let addToLibraryButton = UIButton(type: .system)
    private let cardsSectionTitle = UILabel()
    private let cardsStack = UIStackView()
    private let addCardButton = UIButton(type: .system)

    private var flashcards: [DeckSetDetailModels.FlashcardRow] = []
    private var answerHiddenById: [UUID: Bool] = [:]
    private var isEditingCards = false

    private let profilePurple = UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
    private let glassCorner: CGFloat = 22

    init(deck: LibraryModels.DeckSet) {
        self.deck = deck
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
        flashcards = Self.buildMockCards(for: deck)
        for c in flashcards { answerHiddenById[c.id] = false }

        configureBackground()
        configureScroll()
        configureTopBar()
        configureHeader()
        configureStats()
        configureStudyEntryButtons()
        configureAddToLibrary()
        configureCardsSection()
        configureAddCard()
    }

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
        // Контент доходит до низа экрана, а отступ снизу защищает от перекрытия плавающим таббаром.
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

    private func configureTopBar() {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        styleCircleButton(backButton, symbol: "chevron.left")
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)

        let editCfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        editButton.setImage(UIImage(systemName: "pencil", withConfiguration: editCfg), for: .normal)
        editButton.setTitle(" Редактировать", for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        editButton.tintColor = .white
        editButton.backgroundColor = .white.withAlphaComponent(0.22)
        editButton.layer.cornerRadius = 20
        editButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 14)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        editButton.isHidden = !deck.isUserOwned

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

    private func configureHeader() {
        folderIcon.image = UIImage(systemName: "folder.fill")
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

        let authorName = deck.isUserOwned ? "lzkgmr" : "сообщество"
        authorLabel.text = "Автор: \(authorName)"
        authorLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        authorLabel.textColor = UIColor.white.withAlphaComponent(0.78)

        let df = DateFormatter()
        df.locale = Locale(identifier: "ru_RU")
        df.dateFormat = "dd.MM.yyyy"
        createdLabel.text = "Создан: \(df.string(from: deck.addedAt))"
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

    private func configureStats() {
        statsContainer.backgroundColor = .white.withAlphaComponent(0.22)
        statsContainer.layer.cornerRadius = glassCorner
        statsContainer.layer.borderWidth = 1
        statsContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        statsContainer.translatesAutoresizingMaskIntoConstraints = false

        statsStack.axis = .vertical
        statsStack.spacing = 10
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        let learned = deck.learned
        let unlearned = max(0, deck.total - deck.learned)
        let pct: Int = {
            guard deck.total > 0 else { return 0 }
            return Int(round(Double(learned) / Double(deck.total) * 100))
        }()

        statsStack.addArrangedSubview(statLine(title: "Изучено карточек", value: "\(learned)"))
        statsStack.addArrangedSubview(statLine(title: "Не изучено", value: "\(unlearned)"))
        statsStack.addArrangedSubview(statLine(title: "Всего карточек", value: "\(deck.total)"))
        statsStack.addArrangedSubview(statLine(title: "Процент изучения", value: "\(pct)%"))

        statsContainer.addSubview(statsStack)
        NSLayoutConstraint.activate([
            statsStack.topAnchor.constraint(equalTo: statsContainer.topAnchor, constant: 14),
            statsStack.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor, constant: -14)
        ])

        contentStack.addArrangedSubview(statsContainer)
    }

    private func configureStudyEntryButtons() {
        studyActionsStack.axis = .vertical
        studyActionsStack.spacing = 10
        studyActionsStack.alignment = .fill

        rememberNotRememberButton.setTitle("Помню / Не помню", for: .normal)
        rememberNotRememberButton.setTitleColor(.white, for: .normal)
        rememberNotRememberButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        rememberNotRememberButton.backgroundColor = deckFolderTint.withAlphaComponent(0.55)
        rememberNotRememberButton.layer.cornerRadius = glassCorner
        rememberNotRememberButton.layer.borderWidth = 1
        rememberNotRememberButton.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        rememberNotRememberButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        rememberNotRememberButton.addTarget(self, action: #selector(rememberNotRememberStudyTapped), for: .touchUpInside)

        typeAnswerButton.setTitle("Ввести ответ", for: .normal)
        typeAnswerButton.setTitleColor(.white, for: .normal)
        typeAnswerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        typeAnswerButton.backgroundColor = .clear
        typeAnswerButton.layer.cornerRadius = glassCorner
        typeAnswerButton.layer.borderWidth = 1.5
        typeAnswerButton.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        typeAnswerButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        typeAnswerButton.addTarget(self, action: #selector(typeAnswerStudyTapped), for: .touchUpInside)

        let hasCards = deck.total > 0
        rememberNotRememberButton.isEnabled = hasCards
        typeAnswerButton.isEnabled = hasCards
        rememberNotRememberButton.alpha = hasCards ? 1 : 0.45
        typeAnswerButton.alpha = hasCards ? 1 : 0.45

        studyActionsStack.addArrangedSubview(rememberNotRememberButton)
        studyActionsStack.addArrangedSubview(typeAnswerButton)
        contentStack.addArrangedSubview(studyActionsStack)
        contentStack.setCustomSpacing(12, after: statsContainer)
    }

    private func statLine(title: String, value: String) -> UIView {
        let t = UILabel()
        t.text = title
        t.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        t.textColor = UIColor.white.withAlphaComponent(0.8)

        let v = UILabel()
        v.text = value
        v.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        v.textColor = .white
        v.textAlignment = .right
        v.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [t, v])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .fill
        return row
    }

    private func configureAddToLibrary() {
        addToLibraryButton.isHidden = deck.isUserOwned
        addToLibraryButton.setTitle("Добавить в библиотеку", for: .normal)
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

    private func configureCardsSection() {
        cardsSectionTitle.text = "Карточки"
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
            row.onDeleteTap = { [weak self] in self?.confirmDeleteCard(id: card.id) }
            row.onMoreTap = { [weak self] source in
                self?.presentCardMenu(cardId: card.id, sourceView: source)
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

    @objc
    private func backTapped() {
        dismiss(animated: true)
    }

    @objc
    private func editTapped() {
        isEditingCards.toggle()
        let editCfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        if isEditingCards {
            editButton.setImage(UIImage(systemName: "checkmark", withConfiguration: editCfg), for: .normal)
            editButton.setTitle(" Готово", for: .normal)
        } else {
            editButton.setImage(UIImage(systemName: "pencil", withConfiguration: editCfg), for: .normal)
            editButton.setTitle(" Редактировать", for: .normal)
        }
        rebuildCardRows()
    }

    @objc
    private func rememberNotRememberStudyTapped() {
        let study = FlashcardStudyViewController(deck: deck)
        study.modalPresentationStyle = .fullScreen
        present(study, animated: true)
    }

    @objc
    private func typeAnswerStudyTapped() {
        let a = UIAlertController(
            title: "Ввести ответ",
            message: "Режим ввода ответа появится в следующих версиях.",
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc
    private func addToLibraryTapped() {
        let a = UIAlertController(
            title: "В библиотеку",
            message: "Добавление чужого набора в библиотеку будет доступно после подключения API.",
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc
    private func addCardTapped() {
        let a = UIAlertController(title: nil, message: "Создание карточки появится в следующей версии.", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    private func presentCardMenu(cardId: UUID, sourceView: UIView) {
        _ = cardId
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Изменить", style: .default) { [weak self] _ in
            let a = UIAlertController(
                title: "Изменить",
                message: "Экран редактирования карточки будет позже.",
                preferredStyle: .alert
            )
            a.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(a, animated: true)
        })
        sheet.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        if let pop = sheet.popoverPresentationController {
            pop.sourceView = sourceView
            pop.sourceRect = sourceView.bounds
        }
        present(sheet, animated: true)
    }

    private func toggleAnswerVisibility(cardId: UUID) {
        let cur = answerHiddenById[cardId] ?? false
        answerHiddenById[cardId] = !cur
        rebuildCardRows()
    }

    private func confirmDeleteCard(id: UUID) {
        let a = UIAlertController(title: "Удалить карточку?", message: nil, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        a.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.flashcards.removeAll { $0.id == id }
            self?.answerHiddenById[id] = nil
            self?.rebuildCardRows()
        })
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

    /// До API: ограниченный список карточек для прокрутки.
    private static func buildMockCards(for deck: LibraryModels.DeckSet) -> [DeckSetDetailModels.FlashcardRow] {
        let n = min(deck.total, 60)
        guard n > 0 else { return [] }
        return (1...n).map { i in
            DeckSetDetailModels.FlashcardRow(
                id: UUID(),
                question: "Пример вопроса \(i)",
                answer: "Пример ответа \(i)"
            )
        }
    }
}
