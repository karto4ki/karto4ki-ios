import UIKit

final class LibraryDeckRowView: UIView {

    var onTap: (() -> Void)?
    var onDeleteTap: (() -> Void)?

    private let card = UIView()
    private let rootStack = UIStackView()
    private let deleteButton = UIButton(type: .system)
    private let folderIcon = UIImageView()
    private let textStack = UIStackView()
    private let titleLabel = UILabel()
    private let progressCaptionLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let metaLabel = UILabel()
    private let chevron = UIImageView()

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
        rootStack.alignment = .center
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

        folderIcon.contentMode = .scaleAspectFit
        folderIcon.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)
        folderIcon.translatesAutoresizingMaskIntoConstraints = false
        folderIcon.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            folderIcon.widthAnchor.constraint(equalToConstant: 40),
            folderIcon.heightAnchor.constraint(equalToConstant: 40)
        ])

        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.alignment = .fill

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        progressCaptionLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        progressCaptionLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        progressView.trackTintColor = .white.withAlphaComponent(0.35)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.setContentCompressionResistancePriority(.required, for: .vertical)

        metaLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        metaLabel.textColor = UIColor.white.withAlphaComponent(0.72)

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(progressCaptionLabel)
        textStack.addArrangedSubview(progressView)
        textStack.addArrangedSubview(metaLabel)

        let chevCfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevron.image = UIImage(systemName: "chevron.right", withConfiguration: chevCfg)
        chevron.tintColor = .white.withAlphaComponent(0.9)
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        rootStack.addArrangedSubview(deleteButton)
        rootStack.addArrangedSubview(folderIcon)
        rootStack.addArrangedSubview(textStack)
        rootStack.addArrangedSubview(chevron)

        addSubview(card)
        card.addSubview(rootStack)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor),

            rootStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            rootStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            rootStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            rootStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        card.addGestureRecognizer(tap)
    }

    func configure(deck: LibraryModels.DeckSet, createdText: String, isEditing: Bool) {
        titleLabel.text = deck.title
        progressCaptionLabel.text = "выучено: \(deck.learned) из \(deck.total)"
        metaLabel.text = createdText
        
        let c = LibraryModels.FolderPalette.folderColor(colorIndex: deck.colorIndex)
        folderIcon.image = UIImage(systemName: "folder.fill")
        folderIcon.tintColor = c
        progressView.progressTintColor = c
        progressView.progress = Float(max(0, min(1, deck.progress)))
        
        deleteWidth?.constant = isEditing ? 36 : 0
        chevron.isHidden = isEditing
        deleteButton.isUserInteractionEnabled = isEditing
    }

    @objc
    private func rowTapped() {
        onTap?()
    }

    @objc
    private func deleteTapped() {
        onDeleteTap?()
    }
}
