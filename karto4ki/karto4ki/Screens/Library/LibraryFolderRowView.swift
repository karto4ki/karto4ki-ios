import UIKit

final class LibraryFolderRowView: UIView {

    var onTap: (() -> Void)?
    var onDeleteTap: (() -> Void)?

    private let card = UIView()
    private let rootStack = UIStackView()
    private let deleteButton = UIButton(type: .system)
    private let folderIcon = UIImageView()
    private let titleLabel = UILabel()
    private let chevron = UIImageView()

    private var deleteWidth: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
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

        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1

        let chevCfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevron.tintColor = .white.withAlphaComponent(0.9)
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)
        chevron.preferredSymbolConfiguration = chevCfg

        rootStack.addArrangedSubview(deleteButton)
        rootStack.addArrangedSubview(folderIcon)
        rootStack.addArrangedSubview(titleLabel)
        rootStack.addArrangedSubview(chevron)

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

        let tap = UITapGestureRecognizer(target: self, action: #selector(rowTapped))
        card.addGestureRecognizer(tap)
    }

    func configure(folder: LibraryFolder, isEditing: Bool, isExpanded: Bool) {
        titleLabel.text = folder.name
        let c = LibraryModels.FolderPalette.folderColor(colorIndex: folder.colorIndex)
        folderIcon.image = UIImage(systemName: "folder.fill")
        folderIcon.tintColor = c

        let chevSymbol = isExpanded ? "chevron.down" : "chevron.right"
        let chevCfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        chevron.image = UIImage(systemName: chevSymbol, withConfiguration: chevCfg)
        chevron.isHidden = isEditing

        deleteWidth?.constant = isEditing ? 36 : 0
        deleteButton.isUserInteractionEnabled = isEditing
    }

    @objc private func rowTapped() { onTap?() }
    @objc private func deleteTapped() { onDeleteTap?() }
}
