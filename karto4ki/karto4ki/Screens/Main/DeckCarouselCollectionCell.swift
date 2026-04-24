import UIKit

final class DeckCarouselCollectionCell: UICollectionViewCell {

    static let reuseId = "DeckCarouselCollectionCell"

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

    /// Три строки (futuraB15 ≈ 18pt по высоте) + два равных промежутка при `.equalSpacing`.
    private static let statsBlockHeight: CGFloat = 3 * 18 + 2 * 10 + 6
    /// Расстояние между дугой процентов и блоком лейблов (визуально «тянет» карточку прогресса вниз).
    private static let gaugeToStatsVerticalGap: CGFloat = 20

    /// Высота ячейки: `collectionWidth` — ширина клипа карусели, `interItemGap` — зазор между колодами при свайпе.
    static func contentHeight(collectionWidth: CGFloat, interItemGap: CGFloat) -> CGFloat {
        let itemW = max(0, collectionWidth - interItemGap)
        let gaugeW = max(0, itemW - 40)
        let gaugeH = gaugeW * 0.55
        let progressBlock = 20 + gaugeH + Self.gaugeToStatsVerticalGap + statsBlockHeight + 20
        return 90 + 16 + progressBlock
    }

    // MARK: - Private

    private func configure() {
        contentView.backgroundColor = .clear

        styleCard(deckCard)
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
        rowStack.spacing = 20
        rowStack.alignment = .center

        deckCard.addSubview(rowStack)
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStack.leadingAnchor.constraint(equalTo: deckCard.leadingAnchor, constant: 16),
            rowStack.trailingAnchor.constraint(equalTo: deckCard.trailingAnchor, constant: -16),
            rowStack.topAnchor.constraint(equalTo: deckCard.topAnchor, constant: 14),
            rowStack.bottomAnchor.constraint(equalTo: deckCard.bottomAnchor, constant: -14)
        ])

        styleCard(progressCard)
        gaugeView.translatesAutoresizingMaskIntoConstraints = false
        progressCard.addSubview(gaugeView)

        learnedLabel.font = Fonts.futuraB14
        learnedLabel.textColor = .white.withAlphaComponent(0.9)
        learnedLabel.textAlignment = .center
        learnedLabel.numberOfLines = 1
        learnedLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        notLearnedLabel.font = Fonts.futuraB14
        notLearnedLabel.textColor = .white.withAlphaComponent(0.9)
        notLearnedLabel.textAlignment = .center
        notLearnedLabel.numberOfLines = 1
        notLearnedLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        errorsLabel.font = Fonts.futuraB14
        errorsLabel.textAlignment = .center
        errorsLabel.numberOfLines = 1
        errorsLabel.adjustsFontSizeToFitWidth = true
        errorsLabel.minimumScaleFactor = 0.85
        errorsLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let statsStack = UIStackView(arrangedSubviews: [learnedLabel, notLearnedLabel, errorsLabel])
        statsStack.axis = .vertical
        statsStack.distribution = .equalSpacing
        statsStack.spacing = 8
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
            gaugeView.topAnchor.constraint(equalTo: progressCard.topAnchor, constant: 20),
            gaugeView.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor, constant: 20),
            gaugeView.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor, constant: -20),
            gaugeView.heightAnchor.constraint(equalTo: gaugeView.widthAnchor, multiplier: 0.55),

            statsStack.topAnchor.constraint(equalTo: gaugeView.bottomAnchor, constant: Self.gaugeToStatsVerticalGap),
            statsStack.leadingAnchor.constraint(equalTo: progressCard.leadingAnchor, constant: 16),
            statsStack.trailingAnchor.constraint(equalTo: progressCard.trailingAnchor, constant: -16),
            progressCard.bottomAnchor.constraint(equalTo: statsStack.bottomAnchor, constant: 20)
        ])

        let deckProgressStack = UIStackView(arrangedSubviews: [deckCard, progressCard])
        deckProgressStack.axis = .vertical
        deckProgressStack.spacing = 16
        deckProgressStack.alignment = .fill

        let column = UIStackView(arrangedSubviews: [deckProgressStack, verticalFiller])
        column.axis = .vertical
        column.spacing = 0
        column.alignment = .fill
        deckCard.setContentHuggingPriority(.defaultHigh, for: .vertical)

        contentView.addSubview(column)
        column.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            column.topAnchor.constraint(equalTo: contentView.topAnchor),
            column.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            column.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            column.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
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
