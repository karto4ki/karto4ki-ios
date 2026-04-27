import UIKit

/// Одна страница: колода + статистика (без коллекции, только верстка).
final class DeckCarouselPanelView: UIView {

    /// Вертикальный шаг между колодой и статистикой — как `MainScreenCardLayout` на главной.
    static let verticalBlockSpacing: CGFloat = 10

    private let deckCard = UIView()
    private let deckTitleLabel = UILabel()
    private let deckAuthorLabel = UILabel()
    private let deckCountLabel = UILabel()

    private let progressCard = UIView()
    private let gaugeView = SemicircleGaugeView()
    private let learnedLabel = UILabel()
    private let notLearnedLabel = UILabel()
    private let errorsLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: MainScreenModels.DeckCarouselItem) {
        let deck = item.deck
        let p = item.progress

        deckTitleLabel.text = deck.title
        deckAuthorLabel.text = "* автор: \(deck.author)"
        deckCountLabel.text = "* \(deck.cardCount) карточки"

        gaugeView.setProgress(p.percent)
        learnedLabel.text = "изученные: \(p.learned)"
        notLearnedLabel.text = "не изученные: \(p.notLearned)"
        errorsLabel.attributedText = NSAttributedString(
            string: "с ошибками: \(p.withErrors)",
            attributes: [.foregroundColor: UIColor(red: 0.95, green: 0.30, blue: 0.35, alpha: 1)]
        )
    }

    private enum Layout {
        static let deckCardHeight: CGFloat = 86
        static let deckProgressSpacing: CGFloat = DeckCarouselPanelView.verticalBlockSpacing
        static let gaugeTop: CGFloat = 10
        static let gaugeHorizontalInset: CGFloat = MainScreenCardLayout.horizontalContentInset
        static let gaugeHeightMultiplier: CGFloat = 0.46
        static let gaugeToStatsGap: CGFloat = 6
        static let statsHorizontalInset: CGFloat = MainScreenCardLayout.horizontalContentInset
        static let statsStackMinSpacing: CGFloat = 4
        static let progressBottomPadding: CGFloat = 10
        static let statsBlockHeight: CGFloat = 3 * 15 + 2 * statsStackMinSpacing + 4
    }

    static func contentHeight(panelWidth: CGFloat) -> CGFloat {
        let w = max(0, panelWidth)
        let gaugeW = max(0, w - 2 * MainScreenCardLayout.horizontalContentInset)
        let gaugeH = gaugeW * Layout.gaugeHeightMultiplier
        let progressBlock = Layout.gaugeTop + gaugeH + Layout.gaugeToStatsGap + Layout.statsBlockHeight + Layout.progressBottomPadding
        return Layout.deckCardHeight + Layout.deckProgressSpacing + progressBlock
    }

    private func configure() {
        backgroundColor = .clear

        styleCard(deckCard)
        deckCard.setHeight(Layout.deckCardHeight)

        let cardsIconConfig = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        let cardsIcon = UIImageView(image: UIImage(systemName: "rectangle.on.rectangle.angled", withConfiguration: cardsIconConfig))
        cardsIcon.tintColor = .white.withAlphaComponent(0.9)
        cardsIcon.contentMode = .scaleAspectFit
        cardsIcon.setWidth(42)

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
        infoStack.spacing = 2
        infoStack.alignment = .leading

        let rowStack = UIStackView(arrangedSubviews: [cardsIcon, infoStack])
        rowStack.axis = .horizontal
        rowStack.spacing = 12
        rowStack.alignment = .center

        deckCard.addSubview(rowStack)
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: deckCard.leadingAnchor, constant: MainScreenCardLayout.horizontalContentInset),
            rowStack.trailingAnchor.constraint(equalTo: deckCard.trailingAnchor, constant: -MainScreenCardLayout.horizontalContentInset),
            rowStack.topAnchor.constraint(equalTo: deckCard.topAnchor, constant: 8),
            rowStack.bottomAnchor.constraint(equalTo: deckCard.bottomAnchor, constant: -8)
        ])

        styleCard(progressCard)
        gaugeView.translatesAutoresizingMaskIntoConstraints = false
        progressCard.addSubview(gaugeView)

        let statsFont = UIFont(name: "futuralt-bold", size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .bold)

        learnedLabel.font = statsFont
        learnedLabel.textColor = .white.withAlphaComponent(0.9)
        learnedLabel.textAlignment = .center
        learnedLabel.numberOfLines = 1
        learnedLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        notLearnedLabel.font = statsFont
        notLearnedLabel.textColor = .white.withAlphaComponent(0.9)
        notLearnedLabel.textAlignment = .center
        notLearnedLabel.numberOfLines = 1
        notLearnedLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        errorsLabel.font = statsFont
        errorsLabel.textAlignment = .center
        errorsLabel.numberOfLines = 1
        errorsLabel.adjustsFontSizeToFitWidth = true
        errorsLabel.minimumScaleFactor = 0.85
        errorsLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let statsStack = UIStackView(arrangedSubviews: [learnedLabel, notLearnedLabel, errorsLabel])
        statsStack.axis = .vertical
        statsStack.distribution = .equalSpacing
        statsStack.spacing = Layout.statsStackMinSpacing
        statsStack.alignment = .fill
        statsStack.setContentHuggingPriority(.required, for: .vertical)
        statsStack.setContentCompressionResistancePriority(.required, for: .vertical)

        progressCard.addSubview(statsStack)
        statsStack.translatesAutoresizingMaskIntoConstraints = false

        progressCard.setContentHuggingPriority(.required, for: .vertical)
        progressCard.setContentCompressionResistancePriority(.required, for: .vertical)

        let verticalFiller = UIView()
        verticalFiller.setContentHuggingPriority(.defaultLow, for: .vertical)
        verticalFiller.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        NSLayoutConstraint.activate([
            gaugeView.topAnchor.constraint(equalTo: progressCard.topAnchor, constant: Layout.gaugeTop),
            gaugeView.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor, constant: Layout.gaugeHorizontalInset),
            gaugeView.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor, constant: -Layout.gaugeHorizontalInset),
            gaugeView.heightAnchor.constraint(equalTo: gaugeView.widthAnchor, multiplier: Layout.gaugeHeightMultiplier),

            statsStack.topAnchor.constraint(equalTo: gaugeView.bottomAnchor, constant: Layout.gaugeToStatsGap),
            statsStack.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor, constant: Layout.statsHorizontalInset),
            statsStack.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor, constant: -Layout.statsHorizontalInset),
            progressCard.bottomAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: Layout.progressBottomPadding)
        ])

        let deckProgressStack = UIStackView(arrangedSubviews: [deckCard, progressCard])
        deckProgressStack.axis = .vertical
        deckProgressStack.spacing = Layout.deckProgressSpacing
        deckProgressStack.alignment = .fill

        let column = UIStackView(arrangedSubviews: [deckProgressStack, verticalFiller])
        column.axis = .vertical
        column.spacing = 0
        column.alignment = .fill
        deckCard.setContentHuggingPriority(.defaultHigh, for: .vertical)

        addSubview(column)
        column.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: topAnchor),
            column.leadingAnchor.constraint(equalTo: leadingAnchor),
            column.trailingAnchor.constraint(equalTo: trailingAnchor),
            column.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func styleCard(_ card: UIView) {
        card.backgroundColor = .white.withAlphaComponent(0.28)
        card.layer.cornerRadius = 22
        card.clipsToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
    }
}
