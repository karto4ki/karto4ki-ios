import UIKit

final class DeckSetDetailCardRowView: UIView {

    var onDeleteTap: (() -> Void)?
    var onMoreTap: ((UIView) -> Void)?
    var onEyeTap: (() -> Void)?

    private let card = UIView()
    private let rootStack = UIStackView()
    private let deleteButton = UIButton(type: .system)
    private let innerStack = UIStackView()
    private let topRow = UIStackView()
    private let indexBadge = UILabel()
    private let eyeButton = UIButton(type: .system)
    private let questionTitle = UILabel()
    private let questionBody = UILabel()
    private let separator = UIView()
    private let answerTitle = UILabel()
    private let answerBody = UILabel()
    private let bottomRow = UIStackView()
    private let moreButton = UIButton(type: .system)

    private var deleteWidth: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false

        card.backgroundColor = .white.withAlphaComponent(0.28)
        card.layer.cornerRadius = 22
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.white.withAlphaComponent(0.5).cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        rootStack.axis = .horizontal
        rootStack.alignment = .top
        rootStack.spacing = 8
        rootStack.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        deleteButton.tintColor = UIColor(red: 0.95, green: 0.35, blue: 0.42, alpha: 1)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setContentHuggingPriority(.required, for: .horizontal)
        let dw = deleteButton.widthAnchor.constraint(equalToConstant: 0)
        dw.isActive = true
        deleteWidth = dw

        innerStack.axis = .vertical
        innerStack.spacing = 8
        innerStack.alignment = .fill

        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.spacing = 8

        indexBadge.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        indexBadge.textColor = .white
        indexBadge.textAlignment = .center
        indexBadge.backgroundColor = .clear
        indexBadge.layer.cornerRadius = 14
        indexBadge.clipsToBounds = true
        indexBadge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indexBadge.widthAnchor.constraint(equalToConstant: 28),
            indexBadge.heightAnchor.constraint(equalToConstant: 28)
        ])

        let eyeCfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        eyeButton.setImage(UIImage(systemName: "eye", withConfiguration: eyeCfg), for: .normal)
        eyeButton.tintColor = .white.withAlphaComponent(0.85)
        eyeButton.addTarget(self, action: #selector(eyeTapped), for: .touchUpInside)

        topRow.addArrangedSubview(indexBadge)
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        topRow.addArrangedSubview(spacer)
        topRow.addArrangedSubview(eyeButton)

        func captionStyle(_ label: UILabel, text: String) {
            label.text = text
            label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
            label.textColor = UIColor.white.withAlphaComponent(0.75)
        }

        captionStyle(questionTitle, text: "Вопрос")
        captionStyle(answerTitle, text: "Ответ")

        questionBody.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        questionBody.textColor = .white
        questionBody.numberOfLines = 0

        separator.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        answerBody.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        answerBody.textColor = .white
        answerBody.numberOfLines = 0

        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.addArrangedSubview(UIView())
        let moreCfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        moreButton.setImage(UIImage(systemName: "ellipsis", withConfiguration: moreCfg), for: .normal)
        moreButton.tintColor = .white.withAlphaComponent(0.9)
        moreButton.addTarget(self, action: #selector(moreTapped), for: .touchUpInside)
        bottomRow.addArrangedSubview(moreButton)

        innerStack.addArrangedSubview(topRow)
        innerStack.addArrangedSubview(questionTitle)
        innerStack.addArrangedSubview(questionBody)
        innerStack.addArrangedSubview(separator)
        innerStack.addArrangedSubview(answerTitle)
        innerStack.addArrangedSubview(answerBody)
        innerStack.addArrangedSubview(bottomRow)

        rootStack.addArrangedSubview(deleteButton)
        rootStack.addArrangedSubview(innerStack)

        addSubview(card)
        card.addSubview(rootStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),

            rootStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            rootStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            rootStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            rootStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14)
        ])
    }

    func configure(
        index: Int,
        row: DeckSetDetailModels.FlashcardRow,
        isEditing: Bool,
        answerHidden: Bool,
        accentColor: UIColor
    ) {
        indexBadge.text = "\(index)"
        indexBadge.backgroundColor = accentColor
        questionBody.text = row.question
        answerBody.text = row.answer
        answerBody.textColor = answerHidden ? .clear : .white
        let eyeCfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let sym = answerHidden ? "eye.slash" : "eye"
        eyeButton.setImage(UIImage(systemName: sym, withConfiguration: eyeCfg), for: .normal)

        deleteWidth?.constant = isEditing ? 36 : 0
        deleteButton.isUserInteractionEnabled = isEditing
        moreButton.isEnabled = !isEditing
        moreButton.alpha = isEditing ? 0.35 : 1
        eyeButton.isEnabled = !isEditing
        eyeButton.alpha = isEditing ? 0.35 : 1
    }

    @objc
    private func deleteTapped() {
        onDeleteTap?()
    }

    @objc
    private func moreTapped() {
        onMoreTap?(moreButton)
    }

    @objc
    private func eyeTapped() {
        onEyeTap?()
    }
}
