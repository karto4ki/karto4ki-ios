import UIKit

final class MainScreenViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate,
    UICollectionViewDataSource, UICollectionViewDelegate {

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

    // MARK: - Deck carousel (UICollectionView — видно соседнюю колоду при перетаскивании)
    private let carouselSection = UIStackView()
    private let carouselClipContainer = UIView()
    private let deckPageControl = UIPageControl()
    private let deckFlowLayout = UICollectionViewFlowLayout()
    private lazy var deckCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: deckFlowLayout)
        cv.backgroundColor = .clear
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.alwaysBounceHorizontal = true
        cv.dataSource = self
        cv.delegate = self
        cv.register(DeckCarouselCollectionCell.self, forCellWithReuseIdentifier: DeckCarouselCollectionCell.reuseId)
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()

    private var deckCarouselItems: [MainScreenModels.DeckCarouselItem] = []
    private var lastDeckCarouselLayoutWidth: CGFloat = 0
    /// Зазор между колодами при свайпе; вместе с шириной ячейки даёт шаг ровно в ширину клипа (`isPagingEnabled`).
    private let deckCarouselInterItemGap: CGFloat = 10
    private var carouselClipHeightConstraint: NSLayoutConstraint?

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
        configureCarouselSection()
        interactor.loadData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateDeckCarouselLayoutIfNeeded()
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

    // MARK: - Carousel (колода + прогресс)

    private func configureCarouselSection() {
        carouselSection.axis = .vertical
        carouselSection.spacing = 10
        carouselSection.alignment = .fill

        carouselClipContainer.clipsToBounds = true
        carouselClipContainer.backgroundColor = .clear

        deckFlowLayout.scrollDirection = .horizontal
        deckFlowLayout.minimumLineSpacing = deckCarouselInterItemGap
        deckFlowLayout.minimumInteritemSpacing = 0

        carouselClipContainer.addSubview(deckCollectionView)
        deckCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deckCollectionView.topAnchor.constraint(equalTo: carouselClipContainer.topAnchor),
            deckCollectionView.leadingAnchor.constraint(equalTo: carouselClipContainer.leadingAnchor),
            deckCollectionView.trailingAnchor.constraint(equalTo: carouselClipContainer.trailingAnchor),
            deckCollectionView.bottomAnchor.constraint(equalTo: carouselClipContainer.bottomAnchor)
        ])

        let clipH = carouselClipContainer.heightAnchor.constraint(equalToConstant: 320)
        clipH.priority = .required
        clipH.isActive = true
        carouselClipHeightConstraint = clipH

        // Дефолтный itemSize у flow — мелкий; до первого layout ячейки иначе получают ~50×50 и рвут constraints.
        let provisionalClipW = max(320, UIScreen.main.bounds.width - 40)
        deckFlowLayout.itemSize = deckCarouselItemSize(collectionClipWidth: provisionalClipW)

        deckPageControl.currentPageIndicatorTintColor = UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
        deckPageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.35)
        deckPageControl.isUserInteractionEnabled = false
        deckPageControl.hidesForSinglePage = true

        carouselSection.addArrangedSubview(carouselClipContainer)
        carouselSection.addArrangedSubview(deckPageControl)

        contentStack.addArrangedSubview(carouselSection)
    }

    private func deckCarouselPhysicalItemCount() -> Int {
        let n = deckCarouselItems.count
        if n <= 1 { return n }
        return n + 2
    }

    private func deckCarouselItem(physicalIndex: Int) -> MainScreenModels.DeckCarouselItem? {
        let n = deckCarouselItems.count
        guard n > 0 else { return nil }
        if n == 1 { return deckCarouselItems[0] }
        if physicalIndex == 0 { return deckCarouselItems[n - 1] }
        if physicalIndex == n + 1 { return deckCarouselItems[0] }
        return deckCarouselItems[physicalIndex - 1]
    }

    private func logicalPageIndex(fromPhysical physical: Int) -> Int {
        let n = deckCarouselItems.count
        guard n > 1 else { return 0 }
        if physical <= 0 { return n - 1 }
        if physical >= n + 1 { return 0 }
        return physical - 1
    }

    private func deckCarouselItemSize(collectionClipWidth w: CGFloat) -> CGSize {
        let itemW = w - deckCarouselInterItemGap
        let nh = DeckCarouselCollectionCell.contentHeight(collectionWidth: w, interItemGap: deckCarouselInterItemGap)
        return CGSize(width: itemW, height: nh)
    }

    private func updateDeckCarouselLayoutIfNeeded() {
        let w = carouselClipContainer.bounds.width
        guard w >= 200 else { return }

        let itemSize = deckCarouselItemSize(collectionClipWidth: w)
        carouselClipHeightConstraint?.constant = itemSize.height

        if abs(w - lastDeckCarouselLayoutWidth) < 0.5 {
            return
        }
        lastDeckCarouselLayoutWidth = w

        deckFlowLayout.minimumLineSpacing = deckCarouselInterItemGap
        deckFlowLayout.itemSize = itemSize
        deckFlowLayout.invalidateLayout()

        deckCollectionView.reloadData()
        deckCollectionView.layoutIfNeeded()

        if deckCarouselItems.count > 1 {
            deckCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
        } else if deckCarouselItems.count == 1 {
            deckCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
        }
        updateDeckPageControlFromScrollOffset()
    }

    private func resetDeckCarouselAfterDataLoad() {
        lastDeckCarouselLayoutWidth = 0
        view.layoutIfNeeded()
        updateDeckCarouselLayoutIfNeeded()
    }

    private func fixInfiniteDeckCarouselIfNeeded() {
        let n = deckCarouselItems.count
        guard n > 1 else { return }
        let w = deckCollectionView.bounds.width
        guard w > 0 else { return }
        var page = Int(round(deckCollectionView.contentOffset.x / w))
        if page <= 0 {
            deckCollectionView.scrollToItem(at: IndexPath(item: n, section: 0), at: .left, animated: false)
            page = n
        } else if page >= n + 1 {
            deckCollectionView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .left, animated: false)
            page = 1
        }
        deckPageControl.currentPage = logicalPageIndex(fromPhysical: page)
    }

    private func updateDeckPageControlFromScrollOffset() {
        let n = deckCarouselItems.count
        guard n > 0 else { return }
        let w = deckCollectionView.bounds.width
        guard w > 0 else { return }
        let physical = Int(round(deckCollectionView.contentOffset.x / w))
        deckPageControl.currentPage = logicalPageIndex(fromPhysical: physical)
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
        if otherGestureRecognizer === deckCollectionView.panGestureRecognizer { return true }
        return true
    }
}

// MARK: - Deck carousel (UICollectionView)

extension MainScreenViewController {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        deckCarouselPhysicalItemCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let raw = collectionView.dequeueReusableCell(withReuseIdentifier: DeckCarouselCollectionCell.reuseId, for: indexPath)
        guard let cell = raw as? DeckCarouselCollectionCell,
              let item = deckCarouselItem(physicalIndex: indexPath.item) else { return raw }
        cell.configure(with: item)
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === deckCollectionView else { return }
        updateDeckPageControlFromScrollOffset()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === deckCollectionView else { return }
        fixInfiniteDeckCarouselIfNeeded()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView === deckCollectionView, !decelerate else { return }
        fixInfiniteDeckCarouselIfNeeded()
    }
}

// MARK: - DisplayLogic

extension MainScreenViewController: MainScreenDisplayLogic {

    func displayData(_ viewModel: MainScreenModels.ViewModel) {
        deckCarouselItems = viewModel.deckCarousel
        deckPageControl.numberOfPages = max(1, deckCarouselItems.count)
        updateFriends(viewModel.friends)
        updateStreak(viewModel.streakDays)
        resetDeckCarouselAfterDataLoad()
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
