import UIKit
import UniformTypeIdentifiers
import PhotosUI

final class LibraryScreenViewController: UIViewController, UIGestureRecognizerDelegate {

    let interactor: LibraryScreenBusinessLogic
    private let cardService: CardServiceProtocol

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let titleLabel = UILabel()
    private let topButtonsStack = UIStackView()
    private let editButton = UIButton(type: .system)
    private let newFolderButton = UIButton(type: .system)
    private let aiGenerateButton = UIButton(type: .system)

    private let searchField = UITextField()
    private let studyAllButton = UIButton(type: .system)
    private let quizAllButton  = UIButton(type: .system)

    private let decksStack = UIStackView()
    private let emptyContainer = UIView()
    private let emptyIcon = UIImageView()
    private let emptyLabel = UILabel()

    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let outsideTap = UITapGestureRecognizer()

    private var allDecks: [LibraryModels.DeckSet] = []
    private var isEditingDecks = false
    private var expandedFolderIds: Set<UUID> = []

    // currentItems[i] mirrors decksStack.arrangedSubviews[i]
    private var currentItems: [LibraryModels.Item] = []

    // Drag state (edit mode only)
    private var dragSnapshot: UIView?
    private var dragSourceRow: UIView?
    private var dragSourceFrame: CGRect = .zero
    private var dragStartTouchPoint: CGPoint = .zero
    private var draggedItemId: UUID?
    private var highlightedFolderView: UIView?

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

    // MARK: - Layout

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

        titleLabel.text = L10n.Library.title
        titleLabel.font = Fonts.futuraB22
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        topButtonsStack.axis = .horizontal
        topButtonsStack.spacing = 10
        topButtonsStack.alignment = .center

        styleCircleButton(aiGenerateButton, symbol: "wand.and.stars")
        aiGenerateButton.addTarget(self, action: #selector(aiGenerateTapped), for: .touchUpInside)

        styleCircleButton(newFolderButton, symbol: "folder.badge.plus")
        newFolderButton.addTarget(self, action: #selector(newFolderTapped), for: .touchUpInside)

        styleCircleButton(editButton, symbol: "pencil")
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        updateEditButtonIcon()

        topButtonsStack.addArrangedSubview(aiGenerateButton)
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
            string: L10n.Main.searchPlaceholder,
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
        studyAllButton.setTitle(L10n.Library.studyAllShort, for: .normal)
        studyAllButton.setTitleColor(.white, for: .normal)
        studyAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        studyAllButton.backgroundColor = profilePurple.withAlphaComponent(0.55)
        studyAllButton.layer.cornerRadius = glassCorner
        studyAllButton.layer.borderWidth = 1
        studyAllButton.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        studyAllButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        studyAllButton.addTarget(self, action: #selector(studyAllTapped), for: .touchUpInside)

        quizAllButton.setTitle(L10n.Quiz.title, for: .normal)
        quizAllButton.setTitleColor(.white, for: .normal)
        quizAllButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        quizAllButton.backgroundColor = .clear
        quizAllButton.layer.cornerRadius = glassCorner
        quizAllButton.layer.borderWidth = 1.5
        quizAllButton.layer.borderColor = UIColor.white.withAlphaComponent(0.65).cgColor
        quizAllButton.contentEdgeInsets = UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        quizAllButton.addTarget(self, action: #selector(quizAllTapped), for: .touchUpInside)

        contentStack.addArrangedSubview(studyAllButton)
        contentStack.addArrangedSubview(quizAllButton)
        contentStack.setCustomSpacing(16, after: quizAllButton)
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

        emptyLabel.text = L10n.Library.empty
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

    // MARK: - Actions

    @objc
    private func searchTextChanged() {
        rebuildItems()
    }

    @objc
    private func studyAllTapped() {
        studyAllButton.isEnabled = false
        studyAllButton.alpha = 0.5
        let studyVC = FlashcardStudyViewController(allCardsWithService: cardService)
        studyVC.onFinished = { [weak self] in
            AppCacheStore.invalidateSets()
            self?.interactor.reloadLibrary()
        }
        present(studyVC, animated: true) { [weak self] in
            self?.studyAllButton.isEnabled = true
            self?.studyAllButton.alpha = 1
        }
    }

    @objc
    private func quizAllTapped() {
        quizAllButton.isEnabled = false
        quizAllButton.alpha = 0.5
        Task {
            do {
                let session = try await cardService.startStudyAll(sessionType: "quiz", limit: 200)
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    quizAllButton.isEnabled = true
                    quizAllButton.alpha = 1
                    let fakeDeck = LibraryModels.DeckSet(
                        id: UUID(), title: L10n.Quiz.title,
                        learned: 0, total: 0, addedAt: Date(), colorIndex: 0
                    )
                    let quizVC = QuizViewController(deck: fakeDeck, session: session, cardService: cardService)
                    quizVC.onFinished = { [weak self] in
                        AppCacheStore.invalidateSets()
                        self?.interactor.reloadLibrary()
                    }
                    present(quizVC, animated: true)
                }
            } catch {
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    quizAllButton.isEnabled = true
                    quizAllButton.alpha = 1
                    displayError(error.localizedDescription)
                }
            }
        }
    }

    @objc
    private func newFolderTapped() {
        let alert = UIAlertController(title: L10n.Library.newFolderTitle, message: L10n.Library.newFolderMessage, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = L10n.Library.newFolderPlaceholder
            tf.autocapitalizationType = .sentences
        }
        let create = UIAlertAction(title: L10n.Common.create, style: .default) { [weak self, weak alert] _ in
            let name = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !name.isEmpty else { return }
            FolderStore.createFolder(name: name)
            self?.rebuildItems()
            self?.updateEmptyVisibility()
        }
        alert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        alert.addAction(create)
        alert.preferredAction = create
        present(alert, animated: true)
    }

    @objc
    private func editTapped() {
        setEditingDecks(!isEditingDecks)
    }

    @objc
    private func aiGenerateTapped() {
        let sheet = UIAlertController(title: L10n.AddDeck.aiTitle, message: L10n.Common.chooseSource, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: L10n.Common.files, style: .default) { [weak self] _ in
            self?.presentDocumentPicker()
        })
        sheet.addAction(UIAlertAction(title: L10n.Profile.avatarLibrary, style: .default) { [weak self] _ in
            self?.presentPhotoPicker()
        })
        sheet.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        present(sheet, animated: true)
    }

    private func presentDocumentPicker() {
        let types: [UTType] = [
            .pdf,
            .plainText,
            UTType(filenameExtension: "docx") ?? .data
        ]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }

    private func presentPhotoPicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentAIGeneration(fileURL: URL) {
        let genVC = AIGenerationViewController(fileURL: fileURL, cardService: cardService)
        genVC.onComplete = { [weak self] deck in
            self?.dismiss(animated: true) {
                self?.interactor.reloadLibrary()
                if let deck {
                    self?.openDeck(deck)
                }
            }
        }
        present(genVC, animated: true)
    }

    private func setEditingDecks(_ editing: Bool) {
        isEditingDecks = editing
        if editing {
            expandedFolderIds.removeAll()
        }
        updateEditButtonIcon()
        rebuildItems()
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
        let tappedRow = decksStack.arrangedSubviews.contains { row in
            !row.isHidden && row.frame.contains(pointInDeckStack)
        }
        if tappedRow { return }
        setEditingDecks(false)
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

    // MARK: - Item building

    private func buildTopLevelItems() -> [LibraryModels.Item] {
        let folders = FolderStore.load()
        let allFolderItemIds = Set(folders.flatMap { $0.itemIds })

        let topDecks = allDecks
            .filter { !allFolderItemIds.contains($0.id) }
            .map { LibraryModels.Item.deck($0) }

        let topFolders = folders.map { LibraryModels.Item.folder($0) }

        return (topDecks + topFolders).sorted { a, b in
            let la = a.lastActivity
            let lb = b.lastActivity
            switch (la, lb) {
            case (let da?, let db?): return da > db
            case (.some, .none):     return true
            case (.none, .some):     return false
            case (.none, .none):     return a.creationDate > b.creationDate
            }
        }
    }

    private func buildDisplayItems() -> [(item: LibraryModels.Item, isChild: Bool)] {
        let q = (searchField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if isEditingDecks {
            let topLevel = buildTopLevelItems()
            if q.isEmpty {
                return topLevel.map { ($0, false) }
            }
            return topLevel.filter { item in
                switch item {
                case .deck(let d): return d.title.lowercased().contains(q)
                case .folder(let f): return f.name.lowercased().contains(q)
                }
            }.map { ($0, false) }
        }

        if !q.isEmpty {
            let folders = FolderStore.load()
            let matchingDecks = allDecks
                .filter { $0.title.lowercased().contains(q) }
                .map { LibraryModels.Item.deck($0) }
            let matchingFolders = folders
                .filter { $0.name.lowercased().contains(q) }
                .map { LibraryModels.Item.folder($0) }
            return (matchingDecks + matchingFolders)
                .sorted { a, b in
                    let la = a.lastActivity, lb = b.lastActivity
                    switch (la, lb) {
                    case (let da?, let db?): return da > db
                    case (.some, .none):     return true
                    case (.none, .some):     return false
                    case (.none, .none):     return a.creationDate > b.creationDate
                    }
                }
                .map { ($0, false) }
        }

        var result: [(LibraryModels.Item, Bool)] = []
        for topItem in buildTopLevelItems() {
            result.append((topItem, false))
            if case .folder(let f) = topItem, expandedFolderIds.contains(f.id) {
                let children = DeckAccessStore.sorted(allDecks.filter { f.itemIds.contains($0.id) })
                for child in children {
                    result.append((.deck(child), true))
                }
            }
        }
        return result
    }

    // MARK: - Row building

    private func rebuildItems() {
        decksStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let displayItems = buildDisplayItems()
        currentItems = displayItems.map { $0.item }

        for (i, (item, isChild)) in displayItems.enumerated() {
            let row = makeItemRow(item: item, index: i, isChild: isChild)
            decksStack.addArrangedSubview(row)
        }
    }

    private func makeItemRow(item: LibraryModels.Item, index: Int, isChild: Bool) -> UIView {
        switch item {
        case .deck(let deck):
            let row = LibraryDeckRowView()
            row.configure(
                deck: deck,
                createdText: LibraryDateFormatting.createdLabel(for: deck.addedAt),
                isEditing: isEditingDecks
            )
            if isEditingDecks {
                row.onTap = nil
                addDragGesture(to: row)
            } else {
                row.onTap = { [weak self] in self?.openDeck(deck) }
            }
            row.onDeleteTap = { [weak self] in self?.confirmDelete(deck) }

            if isChild {
                // Wrap with left indent to show nesting
                return makeChildContainer(for: row, index: index, minHeight: 96)
            }
            row.tag = index
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 96).isActive = true
            return row

        case .folder(let folder):
            let row = LibraryFolderRowView()
            row.configure(
                folder: folder,
                isEditing: isEditingDecks,
                isExpanded: expandedFolderIds.contains(folder.id)
            )
            if isEditingDecks {
                row.onTap = nil
                addDragGesture(to: row)
            } else {
                row.onTap = { [weak self] in self?.toggleFolderExpansion(folder.id) }
            }
            row.onDeleteTap = { [weak self] in self?.confirmDeleteFolder(folder) }
            row.tag = index
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 72).isActive = true
            return row
        }
    }

    private func makeChildContainer(for rowView: UIView, index: Int, minHeight: CGFloat) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = index
        container.addSubview(rowView)
        NSLayoutConstraint.activate([
            rowView.topAnchor.constraint(equalTo: container.topAnchor),
            rowView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            rowView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            rowView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            rowView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight)
        ])
        return container
    }

    private func addDragGesture(to view: UIView) {
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lp.minimumPressDuration = 0.45
        view.addGestureRecognizer(lp)
    }

    // MARK: - Folder actions

    private func toggleFolderExpansion(_ folderId: UUID) {
        if expandedFolderIds.contains(folderId) {
            expandedFolderIds.remove(folderId)
        } else {
            expandedFolderIds.insert(folderId)
        }
        rebuildItems()
    }

    private func confirmDeleteFolder(_ folder: LibraryFolder) {
        let count = folder.itemIds.count
        let msg = count > 0
            ? "\"\(folder.name)\" — \(count) набор(ов) вернётся в библиотеку."
            : "\"\(folder.name)\""
        let a = UIAlertController(title: L10n.Library.deleteFolder, message: msg, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        a.addAction(UIAlertAction(title: L10n.Common.delete, style: .destructive) { [weak self] _ in
            FolderStore.deleteFolder(id: folder.id)
            self?.rebuildItems()
            self?.updateEmptyVisibility()
        })
        present(a, animated: true)
    }

    // MARK: - Drag & drop

    @objc
    private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard isEditingDecks else { return }
        switch gesture.state {
        case .began:
            guard let row = gesture.view else { return }
            let index = row.tag
            guard index < currentItems.count else { return }
            startDrag(row: row, index: index, gesture: gesture)
        case .changed:
            updateDrag(gesture: gesture)
        case .ended:
            endDrag(dropped: true, gesture: gesture)
        case .cancelled, .failed:
            endDrag(dropped: false, gesture: gesture)
        default:
            break
        }
    }

    private func startDrag(row: UIView, index: Int, gesture: UILongPressGestureRecognizer) {
        draggedItemId = currentItems[index].id
        dragSourceRow = row
        dragStartTouchPoint = gesture.location(in: view)

        let frameInView = view.convert(row.bounds, from: row)
        dragSourceFrame = frameInView

        guard let snapshot = row.snapshotView(afterScreenUpdates: false) else { return }
        snapshot.frame = frameInView
        snapshot.layer.shadowColor = UIColor.black.cgColor
        snapshot.layer.shadowOpacity = 0.35
        snapshot.layer.shadowOffset = CGSize(width: 0, height: 6)
        snapshot.layer.shadowRadius = 10
        view.addSubview(snapshot)
        dragSnapshot = snapshot

        scrollView.isScrollEnabled = false

        UIView.animate(withDuration: 0.2) {
            row.alpha = 0.25
            snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func updateDrag(gesture: UILongPressGestureRecognizer) {
        guard let snapshot = dragSnapshot else { return }
        let touch = gesture.location(in: view)
        let delta = CGPoint(x: touch.x - dragStartTouchPoint.x, y: touch.y - dragStartTouchPoint.y)
        snapshot.center = CGPoint(
            x: dragSourceFrame.midX + delta.x,
            y: dragSourceFrame.midY + delta.y
        )

        let newHighlight = folderRowAt(touch)
        if newHighlight !== highlightedFolderView {
            if let old = highlightedFolderView {
                UIView.animate(withDuration: 0.15) {
                    old.alpha = 1.0
                    old.transform = .identity
                }
            }
            if let new = newHighlight {
                UIView.animate(withDuration: 0.15) {
                    new.alpha = 0.6
                    new.transform = CGAffineTransform(scaleX: 1.03, y: 1.03)
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            highlightedFolderView = newHighlight
        }
    }

    private func endDrag(dropped: Bool, gesture: UILongPressGestureRecognizer) {
        guard let snapshot = dragSnapshot, let sourceRow = dragSourceRow else {
            resetDragState()
            return
        }

        if let highlighted = highlightedFolderView {
            UIView.animate(withDuration: 0.15) {
                highlighted.alpha = 1.0
                highlighted.transform = .identity
            }
        }

        let targetFolderRow = dropped ? highlightedFolderView : nil

        if let targetRow = targetFolderRow,
           let movedId = draggedItemId {
            let idx = targetRow.tag
            guard idx < currentItems.count,
                  case .folder(let folder) = currentItems[idx],
                  movedId != folder.id else {
                bounceBack(snapshot: snapshot, sourceRow: sourceRow)
                resetDragState()
                return
            }
            let folderFrameInView = view.convert(targetRow.bounds, from: targetRow)
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn) {
                snapshot.transform = CGAffineTransform(scaleX: 0.05, y: 0.05)
                snapshot.alpha = 0
                snapshot.center = CGPoint(x: folderFrameInView.midX, y: folderFrameInView.midY)
            } completion: { _ in
                snapshot.removeFromSuperview()
                FolderStore.moveItem(movedId, toFolder: folder.id)
                UIView.animate(withDuration: 0.15) { sourceRow.alpha = 1.0 }
                self.rebuildItems()
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        } else {
            bounceBack(snapshot: snapshot, sourceRow: sourceRow)
        }

        resetDragState()
    }

    private func bounceBack(snapshot: UIView, sourceRow: UIView) {
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5,
            options: []
        ) {
            snapshot.center = CGPoint(x: self.dragSourceFrame.midX, y: self.dragSourceFrame.midY)
            snapshot.transform = .identity
        } completion: { _ in
            snapshot.removeFromSuperview()
            UIView.animate(withDuration: 0.15) { sourceRow.alpha = 1.0 }
        }
    }

    private func resetDragState() {
        dragSnapshot = nil
        dragSourceRow = nil
        draggedItemId = nil
        highlightedFolderView = nil
        scrollView.isScrollEnabled = true
    }

    private func folderRowAt(_ point: CGPoint) -> UIView? {
        let rows = decksStack.arrangedSubviews
        for (i, row) in rows.enumerated() {
            guard i < currentItems.count,
                  case .folder = currentItems[i],
                  row !== dragSourceRow,
                  !row.isHidden else { continue }
            let frameInView = view.convert(row.bounds, from: row)
            if frameInView.contains(point) { return row }
        }
        return nil
    }

    // MARK: - Navigation

    private func openDeck(_ deck: LibraryModels.DeckSet) {
        DeckAccessStore.markOpened(deckId: deck.id)
        let detail = DeckSetDetailViewController(deck: deck, cardService: cardService)
        present(detail, animated: true)
    }

    private func confirmDelete(_ deck: LibraryModels.DeckSet) {
        let a = UIAlertController(
            title: L10n.Library.deleteDeck,
            message: deck.title,
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel))
        a.addAction(UIAlertAction(title: L10n.Common.delete, style: .destructive) { [weak self] _ in
            self?.interactor.deleteDeck(id: deck.id)
        })
        present(a, animated: true)
    }

    private func updateEmptyVisibility() {
        let isEmpty = allDecks.isEmpty && FolderStore.load().isEmpty
        emptyContainer.isHidden = !isEmpty
        decksStack.isHidden = isEmpty
        studyAllButton.isHidden = isEmpty
        quizAllButton.isHidden  = isEmpty
    }
}

// MARK: - UIDocumentPickerDelegate

extension LibraryScreenViewController: UIDocumentPickerDelegate {

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else { return }
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension(url.pathExtension)
        do {
            try FileManager.default.copyItem(at: url, to: tmpURL)
        } catch {
            displayError(error.localizedDescription)
            return
        }
        presentAIGeneration(fileURL: tmpURL)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension LibraryScreenViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }

        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.85) else {
                if error != nil {
                    DispatchQueue.main.async {
                        self?.displayError(error?.localizedDescription ?? L10n.Common.error)
                    }
                }
                return
            }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")
            do {
                try data.write(to: tmpURL)
            } catch {
                DispatchQueue.main.async {
                    self?.displayError(error.localizedDescription)
                }
                return
            }
            DispatchQueue.main.async {
                self?.presentAIGeneration(fileURL: tmpURL)
            }
        }
    }
}

// MARK: - LibraryScreenDisplayLogic

extension LibraryScreenViewController: LibraryScreenDisplayLogic {

    func displayDecks(_ viewModel: LibraryModels.ViewModel) {
        allDecks = viewModel.decks
        if viewModel.isEmpty && FolderStore.load().isEmpty {
            isEditingDecks = false
        }
        updateEmptyVisibility()
        rebuildItems()
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
