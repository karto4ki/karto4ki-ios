import UIKit

final class LibraryScreenViewController: UIViewController, UIGestureRecognizerDelegate {

    let interactor: LibraryScreenBusinessLogic
    private let cardService: CardServiceProtocol

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let titleLabel = UILabel()
    private let topButtonsStack = UIStackView()
    private let editButton = UIButton(type: .system)
    private let newFolderButton = UIButton(type: .system)

    private let searchField = UITextField()
    private let studyAllButton = UIButton(type: .system)

    private let decksStack = UIStackView()
    private let emptyContainer = UIView()
    private let emptyIcon = UIImageView()
    private let emptyLabel = UILabel()

    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let outsideTap = UITapGestureRecognizer()

    private var allDecks: [LibraryModels.DeckSet] = []
    private var isEditingDecks = false

    private let profilePurple = UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
    private let glassCorner: CGFloat = 22

    init(interactor: LibraryScreenBusinessLogic, cardService: CardServiceProtocol) {
        self.interactor = interactor
        self.cardService = cardService
        super.init(nibName: nil, bundle: nil)
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
        configureHeader()
        configureSearch()
        configureStudyAll()
        configureDecksStack()
        configureEmptyState()
        configureLoading()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        interactor.loadLibrary()
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
        scrollView.contentInset.bottom = 100
        scrollView.verticalScrollIndicatorInsets.bottom = 100
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 14
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func configureOutsideTap() {
        outsideTap.addTarget(self, action: #selector(handleOutsideTap))
        outsideTap.cancelsTouchesInView = false
        outsideTap.delegate = self
        scrollView.addGestureRecognizer(outsideTap)
    }

    private func configureHeader() {
        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = "Библиотека"
        titleLabel.font = Fonts.futuraB22
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        topButtonsStack.axis = .horizontal
        topButtonsStack.spacing = 10
        topButtonsStack.alignment = .center

        styleCircleButton(newFolderButton, symbol: "folder.badge.plus")
        newFolderButton.addTarget(self, action: #selector(newFolderTapped), for: .touchUpInside)

        styleCircleButton(editButton, symbol: "pencil")
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        updateEditButtonIcon()

        topButtonsStack.addArrangedSubview(newFolderButton)
        topButtonsStack.addArrangedSubview(editButton)

        row.addSubview(titleLabel)
        row.addSubview(topButtonsStack)
        topButtonsStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 2),
            titleLabel.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            topButtonsStack.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            topButtonsStack.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            topButtonsStack.topAnchor.constraint(equalTo: row.topAnchor),
            topButtonsStack.bottomAnchor.constraint(equalTo: row.bottomAnchor),

            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: topButtonsStack.leadingAnchor, constant: -8),
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
        ])

        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(18, after: row)
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

    private func configureSearch() {
        searchField.returnKeyType = .search
        searchField.autocorrectionType = .no
        searchField.autocapitalizationType = .none
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        searchField.attributedPlaceholder = NSAttributedString(
            string: "найдите карточки...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )
        searchField.font = Fonts.futuraB14
        searchField.textColor = .white
        searchField.backgroundColor = .white.withAlphaComponent(0.25)
        searchField.layer.cornerRadius = 22
        searchField.layer.borderWidth = 1
        searchField.layer.borderColor = UIColor.white.withAlphaComponent(0.6).cgColor
        searchField.setHeight(44)

        let rowHeight: CGFloat = 44
        let leftPad: CGFloat = 12
        let iconSize: CGFloat = 18
        let leftWidth = leftPad + iconSize + 10
        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: leftWidth, height: rowHeight))
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: iconCfg))
        searchIcon.tintColor = .white.withAlphaComponent(0.7)
        searchIcon.frame = CGRect(x: leftPad, y: (rowHeight - iconSize) / 2, width: iconSize, height: iconSize)
        leftContainer.addSubview(searchIcon)
        searchField.leftView = leftContainer
        searchField.leftViewMode = .always
        let rightPad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: rowHeight))
        searchField.rightView = rightPad
        searchField.rightViewMode = .always

        contentStack.addArrangedSubview(searchField)
    }

    private func configureStudyAll() {
        studyAllButton.setTitle("Изучать все карточки", for: .normal)
        studyAllButton.setTitleColor(.white, for: .normal)
        studyAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        studyAllButton.backgroundColor = profilePurple.withAlphaComponent(0.55)
        studyAllButton.layer.cornerRadius = glassCorner
        studyAllButton.layer.borderWidth = 1
        studyAllButton.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        studyAllButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        studyAllButton.addTarget(self, action: #selector(studyAllTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(studyAllButton)
        contentStack.setCustomSpacing(16, after: studyAllButton)
    }

    private func configureDecksStack() {
        decksStack.axis = .vertical
        decksStack.spacing = 12
        decksStack.alignment = .fill
        contentStack.addArrangedSubview(decksStack)
    }

    private func configureEmptyState() {
        emptyContainer.isHidden = true
        emptyContainer.translatesAutoresizingMaskIntoConstraints = false

        let cfg = UIImage.SymbolConfiguration(pointSize: 72, weight: .light)
        emptyIcon.image = UIImage(systemName: "eyes", withConfiguration: cfg)
        emptyIcon.tintColor = profilePurple.withAlphaComponent(0.85)
        emptyIcon.contentMode = .scaleAspectFit
        emptyIcon.translatesAutoresizingMaskIntoConstraints = false

        emptyLabel.text = "Ваша библиотека пока пустая.\nДобавьте новые наборы!"
        emptyLabel.textColor = profilePurple.withAlphaComponent(0.85)
        emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyLabel.textAlignment = .center
        emptyLabel.numberOfLines = 0

        let inner = UIStackView(arrangedSubviews: [emptyIcon, emptyLabel])
        inner.axis = .vertical
        inner.spacing = 16
        inner.alignment = .center
        inner.translatesAutoresizingMaskIntoConstraints = false

        emptyContainer.addSubview(inner)
        contentStack.addArrangedSubview(emptyContainer)

        NSLayoutConstraint.activate([
            inner.centerXAnchor.constraint(equalTo: emptyContainer.centerXAnchor),
            inner.centerYAnchor.constraint(equalTo: emptyContainer.centerYAnchor, constant: -24),
            inner.leadingAnchor.constraint(greaterThanOrEqualTo: emptyContainer.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(lessThanOrEqualTo: emptyContainer.trailingAnchor, constant: -16),
            emptyIcon.widthAnchor.constraint(equalToConstant: 96),
            emptyIcon.heightAnchor.constraint(equalToConstant: 96),
            emptyContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
        ])
    }

    private func configureLoading() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .white
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40)
        ])
    }

    @objc
    private func searchTextChanged() {
        rebuildDeckRows()
    }

    @objc
    private func studyAllTapped() {
        let a = UIAlertController(
            title: "Изучать все",
            message: "Режим совместного повторения всех наборов появится в следующих версиях.",
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc
    private func newFolderTapped() {
        (parent as? TabContainerViewController)?.selectAddDeckTab(animated: true)
    }

    @objc
    private func editTapped() {
        setEditingDecks(!isEditingDecks)
    }

    private func setEditingDecks(_ editing: Bool) {
        isEditingDecks = editing
        updateEditButtonIcon()
        rebuildDeckRows()
    }

    private func updateEditButtonIcon() {
        let symbol = isEditingDecks ? "checkmark" : "pencil"
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        UIView.performWithoutAnimation {
            editButton.setImage(UIImage(systemName: symbol, withConfiguration: cfg), for: .normal)
            editButton.layoutIfNeeded()
        }
    }

    @objc
    private func handleOutsideTap(_ g: UITapGestureRecognizer) {
        guard isEditingDecks else { return }
        let pointInDeckStack = g.location(in: decksStack)
        let tappedDeckRow = decksStack.arrangedSubviews.contains { row in
            !row.isHidden && row.frame.contains(pointInDeckStack)
        }
        if tappedDeckRow { return }
        setEditingDecks(false)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard gestureRecognizer === outsideTap else { return true }
        var v: UIView? = touch.view
        while let current = v {
            if current is UIControl {
                return false
            }
            v = current.superview
        }
        return true
    }

    private func filteredDecks() -> [LibraryModels.DeckSet] {
        let q = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return allDecks }
        return allDecks.filter { $0.title.lowercased().contains(q) }
    }

    private func rebuildDeckRows() {
        decksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let list = filteredDecks()
        for deck in list {
            let row = LibraryDeckRowView()
            row.configure(
                deck: deck,
                createdText: LibraryDateFormatting.createdLabel(for: deck.addedAt),
                isEditing: isEditingDecks
            )
            if isEditingDecks {
                row.onTap = nil
            } else {
                row.onTap = { [weak self] in self?.openDeck(deck) }
            }
            row.onDeleteTap = { [weak self] in self?.confirmDelete(deck) }
            decksStack.addArrangedSubview(row)
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
        }
    }

    private func openDeck(_ deck: LibraryModels.DeckSet) {
        let detail = DeckSetDetailViewController(deck: deck, cardService: cardService)
        present(detail, animated: true)
    }

    private func confirmDelete(_ deck: LibraryModels.DeckSet) {
        let a = UIAlertController(
            title: "Удалить набор?",
            message: deck.title,
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        a.addAction(UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.interactor.deleteDeck(id: deck.id)
        })
        present(a, animated: true)
    }

    private func updateEmptyVisibility(isEmpty: Bool) {
        emptyContainer.isHidden = !isEmpty
        decksStack.isHidden = isEmpty
        studyAllButton.isHidden = isEmpty
    }
}

extension LibraryScreenViewController: LibraryScreenDisplayLogic {

    func displayDecks(_ viewModel: LibraryModels.ViewModel) {
        allDecks = viewModel.decks
        if viewModel.isEmpty {
            isEditingDecks = false
        }
        updateEmptyVisibility(isEmpty: viewModel.isEmpty)
        rebuildDeckRows()
    }

    func displayLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            scrollView.alpha = 0.55
        } else {
            loadingIndicator.stopAnimating()
            scrollView.alpha = 1
        }
    }

    func displayError(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
