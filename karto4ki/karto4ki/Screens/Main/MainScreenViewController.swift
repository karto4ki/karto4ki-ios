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

    // MARK: - Deck card
    private let deckCard = UIView()
    private let deckTitleLabel  = UILabel()
    private let deckAuthorLabel = UILabel()
    private let deckCountLabel  = UILabel()

    // MARK: - Progress card
    private let progressCard  = UIView()
    private let gaugeView     = SemicircleGaugeView()
    private let learnedLabel  = UILabel()
    private let notLearnedLabel = UILabel()
    private let errorsLabel   = UILabel()

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
        configureDeckCard()
        configureProgressCard()
        interactor.loadData()
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
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -76)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -12),
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
            streakStack.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 10),
            streakStack.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -10),
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

    // MARK: - Deck card

    private func configureDeckCard() {
        styleCard(deckCard)
        contentStack.addArrangedSubview(deckCard)
        deckCard.setHeight(90)

        let cardsIconConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let cardsIcon = UIImageView(image: UIImage(systemName: "rectangle.on.rectangle.angled", withConfiguration: cardsIconConfig))
        cardsIcon.tintColor = .white.withAlphaComponent(0.9)
        cardsIcon.contentMode = .scaleAspectFit
        cardsIcon.setWidth(50)

        deckTitleLabel.font = Fonts.futuraB17
        deckTitleLabel.textColor = .white
        deckTitleLabel.numberOfLines = 2
        deckTitleLabel.adjustsFontSizeToFitWidth = true

        deckAuthorLabel.font = Fonts.futuraB14
        deckAuthorLabel.textColor = .white.withAlphaComponent(0.8)

        deckCountLabel.font = Fonts.futuraB14
        deckCountLabel.textColor = .white.withAlphaComponent(0.8)

        let infoStack = UIStackView(arrangedSubviews: [deckTitleLabel, deckAuthorLabel, deckCountLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 3
        infoStack.alignment = .leading

        let rowStack = UIStackView(arrangedSubviews: [cardsIcon, infoStack])
        rowStack.axis = .horizontal
        rowStack.spacing = 14
        rowStack.alignment = .center

        deckCard.addSubview(rowStack)
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: deckCard.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: deckCard.trailingAnchor, constant: -16),
            rowStack.topAnchor.constraint(equalTo: deckCard.topAnchor, constant: 14),
            rowStack.bottomAnchor.constraint(equalTo: deckCard.bottomAnchor, constant: -14)
        ])
    }

    // MARK: - Progress card

    private func configureProgressCard() {
        styleCard(progressCard)
        contentStack.addArrangedSubview(progressCard)

        gaugeView.translatesAutoresizingMaskIntoConstraints = false
        progressCard.addSubview(gaugeView)

        let statsStack = UIStackView()
        statsStack.axis = .vertical
        statsStack.spacing = 5
        statsStack.alignment = .center

        learnedLabel.font = Fonts.futuraB14
        learnedLabel.textColor = .white.withAlphaComponent(0.9)
        learnedLabel.textAlignment = .center

        notLearnedLabel.font = Fonts.futuraB14
        notLearnedLabel.textColor = .white.withAlphaComponent(0.9)
        notLearnedLabel.textAlignment = .center

        errorsLabel.font = Fonts.futuraB14
        errorsLabel.textAlignment = .center

        statsStack.addArrangedSubview(learnedLabel)
        statsStack.addArrangedSubview(notLearnedLabel)
        statsStack.addArrangedSubview(errorsLabel)

        progressCard.addSubview(statsStack)
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            gaugeView.topAnchor.constraint(equalTo: progressCard.topAnchor, constant: 20),
            gaugeView.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor, constant: 20),
            gaugeView.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor, constant: -20),
            gaugeView.heightAnchor.constraint(equalTo: gaugeView.widthAnchor, multiplier: 0.55),

            statsStack.topAnchor.constraint(equalTo: gaugeView.bottomAnchor, constant: 12),
            statsStack.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor, constant: -16),
            statsStack.bottomAnchor.constraint(equalTo: progressCard.bottomAnchor, constant: -20)
        ])
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
        true
    }
}

// MARK: - DisplayLogic

extension MainScreenViewController: MainScreenDisplayLogic {

    func displayData(_ viewModel: MainScreenModels.ViewModel) {
        updateFriends(viewModel.friends)
        updateStreak(viewModel.streakDays)
        updateDeck(viewModel.recentDeck)
        updateProgress(viewModel.progress)
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

    private func updateDeck(_ deck: MainScreenModels.DeckCard) {
        deckTitleLabel.text  = deck.title
        deckAuthorLabel.text = "* автор: \(deck.author)"
        deckCountLabel.text  = "* \(deck.cardCount) карточки"
    }

    private func updateProgress(_ data: MainScreenModels.ProgressData) {
        gaugeView.setProgress(data.percent)
        learnedLabel.text    = "изученные: \(data.learned)"
        notLearnedLabel.text = "не изученные: \(data.notLearned)"

        let errorsText = NSAttributedString(
            string: "с ошибками: \(data.withErrors)",
            attributes: [.foregroundColor: UIColor(red: 0.95, green: 0.30, blue: 0.35, alpha: 1)]
        )
        errorsLabel.attributedText = errorsText
    }
}
