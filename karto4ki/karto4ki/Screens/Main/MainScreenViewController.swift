import UIKit

final class MainScreenViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    private let interactor: MainScreenBusinessLogic

    // MARK: - Scroll layout
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - Search
    private let searchField = UITextField()

    // MARK: - Friends
    private let friendsStack = UIStackView()

    // MARK: - Streak card
    private let streakCard  = UIView()
    private let streakStack = UIStackView()

    // MARK: - Streak message (под плашкой календаря)
    private let streakMessageCard = UIView()
    private let streakMessageIcon = UIImageView()
    private let streakMessageLabel = UILabel()

    // MARK: - Плейсхолдер (когда библиотека пустая)
    private let statsPlaceholderCard = UIView()

    // MARK: - Deck (свайп — смена страницы без «ведения» пальцем)
    private let carouselSection = UIStackView()
    private let carouselClipContainer = UIView()
    private let deckPageControl = UIPageControl()
    private let deckPanelView = DeckCarouselPanelView()

    private var deckCarouselItems: [MainScreenModels.DeckCarouselItem] = []
    private var deckCarouselIndex: Int = 0
    private var lastDeckPanelLayoutWidth: CGFloat = 0
    private var carouselClipHeightConstraint: NSLayoutConstraint?

    private let mainContentBlockSpacing: CGFloat = DeckCarouselPanelView.verticalBlockSpacing

    // MARK: - Init

    init(interactor: MainScreenBusinessLogic) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        configureBackground()
        configureScrollView()
        configureDismissKeyboardGesture()
        configureSearchField()
        configureFriendsSection()
        configureStreakCard()
        configureStreakMessageCard()
        configureCarouselSection()
        configureStatsPlaceholder()
        interactor.loadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Обновляем карусель при каждом появлении экрана (возврат с вкладки библиотеки, после изучения и т.д.)
        interactor.loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDeckPanelLayoutIfNeeded()
    }

    // MARK: - Background

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
        view.sendSubviewToBack(bg)
    }

    // MARK: - Scroll view

    private func configureScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
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
        contentStack.spacing = mainContentBlockSpacing
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: mainContentBlockSpacing),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -mainContentBlockSpacing),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        scrollView.keyboardDismissMode = .onDrag
    }

    // MARK: - Keyboard

    private func configureDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        scrollView.addGestureRecognizer(tap)
    }

    @objc
    private func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Search field

    private func configureSearchField() {
        searchField.delegate = self
        searchField.returnKeyType = .search
        searchField.autocorrectionType = .no
        searchField.autocapitalizationType = .none

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
        let leadingPad: CGFloat = 12
        let iconSize: CGFloat = 18
        let gapAfterIcon: CGFloat = 10
        let leftWidth = leadingPad + iconSize + gapAfterIcon

        let leftContainer = UIView(frame: CGRect(x: 0, y: 0, width: leftWidth, height: rowHeight))
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: iconConfig))
        searchIcon.tintColor = .white.withAlphaComponent(0.7)
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.frame = CGRect(
            x: leadingPad,
            y: (rowHeight - iconSize) / 2,
            width: iconSize,
            height: iconSize
        )
        leftContainer.addSubview(searchIcon)
        searchField.leftView = leftContainer
        searchField.leftViewMode = .always

        let trailingPad: CGFloat = 14
        let rightPad = UIView(frame: CGRect(x: 0, y: 0, width: trailingPad, height: rowHeight))
        searchField.rightView = rightPad
        searchField.rightViewMode = .always

        contentStack.addArrangedSubview(searchField)
    }

    // MARK: - Friends section

    private func configureFriendsSection() {
        let scrollContainer = UIScrollView()
        scrollContainer.showsHorizontalScrollIndicator = false
        scrollContainer.setHeight(90)
        contentStack.addArrangedSubview(scrollContainer)

        friendsStack.axis = .horizontal
        friendsStack.spacing = 20
        friendsStack.alignment = .center
        scrollContainer.addSubview(friendsStack)
        friendsStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            friendsStack.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor, constant: 4),
            friendsStack.trailingAnchor.constraint(equalTo: scrollContainer.trailingAnchor, constant: -4),
            friendsStack.topAnchor.constraint(equalTo: scrollContainer.topAnchor),
            friendsStack.bottomAnchor.constraint(equalTo: scrollContainer.bottomAnchor),
            friendsStack.heightAnchor.constraint(equalTo: scrollContainer.heightAnchor)
        ])
    }

    private func addFriendView(_ friend: MainScreenModels.Friend) -> UIView {
        let container = UIView()
        container.setWidth(60)

        let avatarSize: CGFloat = 56
        let avatarView = UIView()
        avatarView.backgroundColor = friend.color.withAlphaComponent(0.7)
        avatarView.layer.cornerRadius = avatarSize / 2
        avatarView.layer.borderWidth = 2
        avatarView.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        avatarView.setWidth(avatarSize)
        avatarView.setHeight(avatarSize)

        let initialsLabel = UILabel()
        initialsLabel.text = friend.initials
        initialsLabel.font = UIFont.systemFont(ofSize: 18, weight: .black)
        initialsLabel.textColor = .white
        initialsLabel.textAlignment = .center
        avatarView.addSubview(initialsLabel)
        initialsLabel.translatesAutoresizingMaskIntoConstraints = false
        initialsLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor).isActive = true
        initialsLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = friend.name
        nameLabel.font = UIFont(name: "futuralt-bold", size: 10) ?? UIFont.systemFont(ofSize: 10, weight: .medium)
        nameLabel.textColor = .white.withAlphaComponent(0.9)
        nameLabel.textAlignment = .center
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7

        let vStack = UIStackView(arrangedSubviews: [avatarView, nameLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.alignment = .center

        container.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 4),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -4),
            vStack.centerXAnchor.constraint(equalTo: container.centerXAnchor)
        ])

        return container
    }

    // MARK: - Streak card

    private func configureStreakCard() {
        styleCard(streakCard)
        contentStack.addArrangedSubview(streakCard)

        streakStack.axis = .horizontal
        streakStack.distribution = .fillEqually
        streakStack.alignment = .center
        streakStack.spacing = 4

        streakCard.addSubview(streakStack)
        streakStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            streakStack.topAnchor.constraint(equalTo: streakCard.topAnchor, constant: 14),
            streakStack.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: -14),
            streakStack.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: MainScreenCardLayout.horizontalContentInset),
            streakStack.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -MainScreenCardLayout.horizontalContentInset),
            streakStack.heightAnchor.constraint(equalToConstant: 70)
        ])
    }

    private func addStreakDayView(_ day: MainScreenModels.StreakDay) -> UIView {
        let container = UIView()

        let flameImage: UIImage?
        let flameColor: UIColor

        if day.isActive {
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .bold)
            flameImage = UIImage(systemName: "flame.fill", withConfiguration: config)
            flameColor = day.isCurrent
                ? UIColor(red: 0.40, green: 0.40, blue: 0.90, alpha: 1)
                : UIColor(red: 0.55, green: 0.50, blue: 0.95, alpha: 0.9)
        } else {
            let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
            flameImage = UIImage(systemName: "flame", withConfiguration: config)
            flameColor = UIColor.white.withAlphaComponent(0.35)
        }

        let flameView = UIImageView(image: flameImage)
        flameView.tintColor = flameColor
        flameView.contentMode = .scaleAspectFit

        let dayLabel = UILabel()
        dayLabel.text = day.dayName
        dayLabel.font = UIFont(name: "futuralt-bold", size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .bold)
        dayLabel.textColor = .white.withAlphaComponent(0.85)
        dayLabel.textAlignment = .center

        let dateLabel = UILabel()
        dateLabel.text = day.date
        dateLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        dateLabel.textColor = day.isCurrent
            ? UIColor.white
            : UIColor.white.withAlphaComponent(0.6)
        dateLabel.textAlignment = .center

        let vStack = UIStackView(arrangedSubviews: [flameView, dayLabel, dateLabel])
        vStack.axis = .vertical
        vStack.spacing = 1
        vStack.alignment = .center

        container.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 2),
            vStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -2),
            vStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])

        return container
    }

    private func configureStreakMessageCard() {
        styleCard(streakMessageCard)
        contentStack.addArrangedSubview(streakMessageCard)

        let iconConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)
        streakMessageIcon.image = UIImage(systemName: "flame.fill", withConfiguration: iconConfig)
        streakMessageIcon.tintColor = UIColor(red: 0.98, green: 0.52, blue: 0.32, alpha: 1)
        streakMessageIcon.contentMode = .scaleAspectFit
        streakMessageIcon.setContentCompressionResistancePriority(.required, for: .horizontal)
        streakMessageIcon.setWidth(34)

        streakMessageLabel.font = Fonts.futuraB14
        streakMessageLabel.textColor = .white
        streakMessageLabel.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [streakMessageIcon, streakMessageLabel])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center

        streakMessageCard.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.centerYAnchor.constraint(equalTo: streakMessageCard.centerYAnchor),
            row.topAnchor.constraint(equalTo: streakMessageCard.topAnchor, constant: mainContentBlockSpacing),
            row.bottomAnchor.constraint(equalTo: streakMessageCard.bottomAnchor, constant: -mainContentBlockSpacing),
            row.leadingAnchor.constraint(equalTo: streakMessageCard.leadingAnchor, constant: MainScreenCardLayout.horizontalContentInset),
            row.trailingAnchor.constraint(equalTo: streakMessageCard.trailingAnchor, constant: -MainScreenCardLayout.horizontalContentInset)
        ])
    }

    private func updateStreakMessage(currentStreakDayCount: Int) {
        if currentStreakDayCount == 0 {
            streakMessageLabel.text = L10n.Main.streakEmpty
        } else {
            streakMessageLabel.text = L10n.Main.streakActive(currentStreakDayCount)
        }
    }

    // MARK: - Deck panel + page control

    private func configureCarouselSection() {
        carouselSection.axis = .vertical
        carouselSection.spacing = 0
        carouselSection.alignment = .fill

        carouselClipContainer.clipsToBounds = true
        carouselClipContainer.backgroundColor = .clear

        carouselClipContainer.addSubview(deckPanelView)
        deckPanelView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deckPanelView.topAnchor.constraint(equalTo: carouselClipContainer.topAnchor),
            deckPanelView.leadingAnchor.constraint(equalTo: carouselClipContainer.leadingAnchor),
            deckPanelView.trailingAnchor.constraint(equalTo: carouselClipContainer.trailingAnchor),
            deckPanelView.bottomAnchor.constraint(equalTo: carouselClipContainer.bottomAnchor)
        ])

        let clipH = carouselClipContainer.heightAnchor.constraint(equalToConstant: 320)
        clipH.priority = .required
        clipH.isActive = true
        carouselClipHeightConstraint = clipH

        let provisionalW = max(320, UIScreen.main.bounds.width - 40)
        carouselClipHeightConstraint?.constant = DeckCarouselPanelView.contentHeight(panelWidth: provisionalW)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleDeckSwipe(_:)))
        swipeLeft.direction = .left
        carouselClipContainer.addGestureRecognizer(swipeLeft)

        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleDeckSwipe(_:)))
        swipeRight.direction = .right
        carouselClipContainer.addGestureRecognizer(swipeRight)

        deckPageControl.currentPageIndicatorTintColor = UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
        deckPageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.35)
        deckPageControl.isUserInteractionEnabled = false
        deckPageControl.hidesForSinglePage = true
        deckPageControl.setContentHuggingPriority(.required, for: .vertical)
        deckPageControl.setContentCompressionResistancePriority(.required, for: .vertical)

        carouselSection.addArrangedSubview(carouselClipContainer)
        carouselSection.addArrangedSubview(deckPageControl)

        contentStack.addArrangedSubview(carouselSection)
    }

    @objc
    private func handleDeckSwipe(_ gr: UISwipeGestureRecognizer) {
        let n = deckCarouselItems.count
        guard n > 1 else { return }
        switch gr.direction {
        case .left:
            let next = (deckCarouselIndex + 1) % n
            showDeckPage(index: next, animated: true)
        case .right:
            let prev = (deckCarouselIndex - 1 + n) % n
            showDeckPage(index: prev, animated: true)
        default:
            break
        }
    }

    private func showDeckPage(index: Int, animated: Bool) {
        guard index >= 0, index < deckCarouselItems.count else { return }
        deckCarouselIndex = index
        let item = deckCarouselItems[index]
        let apply = { self.deckPanelView.configure(with: item) }
        if animated {
            UIView.transition(with: deckPanelView, duration: 0.28, options: .transitionCrossDissolve, animations: apply)
        } else {
            apply()
        }
        deckPageControl.currentPage = index
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func updateDeckPanelLayoutIfNeeded() {
        let w = carouselClipContainer.bounds.width
        guard w >= 200 else { return }

        let nh = DeckCarouselPanelView.contentHeight(panelWidth: w)
        carouselClipHeightConstraint?.constant = nh

        if abs(w - lastDeckPanelLayoutWidth) < 0.5 {
            return
        }
        lastDeckPanelLayoutWidth = w

        if !deckCarouselItems.isEmpty {
            let idx = min(deckCarouselIndex, max(0, deckCarouselItems.count - 1))
            showDeckPage(index: idx, animated: false)
        }
    }

    private func resetDeckPanelAfterDataLoad() {
        let isEmpty = deckCarouselItems.isEmpty
        carouselSection.isHidden = isEmpty
        statsPlaceholderCard.isHidden = !isEmpty

        deckCarouselIndex = 0
        lastDeckPanelLayoutWidth = 0
        view.layoutIfNeeded()
        updateDeckPanelLayoutIfNeeded()
        if isEmpty { return }
        showDeckPage(index: 0, animated: false)
    }

    // MARK: - Stats placeholder

    private func configureStatsPlaceholder() {
        styleCard(statsPlaceholderCard)
        statsPlaceholderCard.isHidden = true

        let label = UILabel()
        label.text = L10n.Main.statsPlaceholder
        label.font = Fonts.futuraB17
        label.textColor = .white.withAlphaComponent(0.6)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false

        statsPlaceholderCard.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: statsPlaceholderCard.topAnchor, constant: 36),
            label.bottomAnchor.constraint(equalTo: statsPlaceholderCard.bottomAnchor, constant: -36),
            label.leadingAnchor.constraint(equalTo: statsPlaceholderCard.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: statsPlaceholderCard.trailingAnchor, constant: -20)
        ])

        contentStack.addArrangedSubview(statsPlaceholderCard)
    }

    // MARK: - Helpers

    private func styleCard(_ card: UIView) {
        card.backgroundColor = .white.withAlphaComponent(0.28)
        card.layer.cornerRadius = 22
        card.clipsToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    }
}

// MARK: - UITextFieldDelegate & keyboard gesture

extension MainScreenViewController {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        touch.view is UIControl ? false : true
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if otherGestureRecognizer === scrollView.panGestureRecognizer { return true }
        return true
    }
}

// MARK: - DisplayLogic

extension MainScreenViewController: MainScreenDisplayLogic {

    func displayData(_ viewModel: MainScreenModels.ViewModel) {
        deckCarouselItems = viewModel.deckCarousel
        deckPageControl.numberOfPages = max(1, deckCarouselItems.count)
        updateFriends(viewModel.friends)
        updateStreak(viewModel.streakDays)
        updateStreakMessage(currentStreakDayCount: viewModel.currentStreakDayCount)
        resetDeckPanelAfterDataLoad()
    }

    private func updateFriends(_ friends: [MainScreenModels.Friend]) {
        friendsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        friends.forEach { friend in
            friendsStack.addArrangedSubview(addFriendView(friend))
        }
    }

    private func updateStreak(_ days: [MainScreenModels.StreakDay]) {
        streakStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        days.forEach { day in
            streakStack.addArrangedSubview(addStreakDayView(day))
        }
    }
}
