import UIKit

final class AIGenerationViewController: UIViewController {

    // MARK: - Callbacks

    var onComplete: ((LibraryModels.DeckSet?) -> Void)?

    // MARK: - Dependencies

    private let fileURL: URL
    private let cardService: CardServiceProtocol

    // MARK: - UI

    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let cancelButton = UIButton(type: .system)

    private var generationTask: Task<Void, Never>?

    // MARK: - Init

    init(fileURL: URL, cardService: CardServiceProtocol) {
        self.fileURL = fileURL
        self.cardService = cardService
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackground()
        configureIcon()
        configureLabels()
        configureCancel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startIconAnimation()
        startGeneration()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        generationTask?.cancel()
    }

    // MARK: - Layout

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
    }

    private func configureIcon() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 64, weight: .light)
        iconView.image = UIImage(systemName: "wand.and.stars", withConfiguration: cfg)
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit

        view.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            iconView.widthAnchor.constraint(equalToConstant: 90),
            iconView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }

    private func configureLabels() {
        titleLabel.text = L10n.AIGeneration.title
        titleLabel.font = Fonts.futuraB17
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        subtitleLabel.text = L10n.AIGeneration.subtitle
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.65)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])
    }

    private func configureCancel() {
        cancelButton.setTitle(L10n.Common.cancel, for: .normal)
        cancelButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)

        view.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    // MARK: - Animations

    private func startIconAnimation() {
        let pulse = CAKeyframeAnimation(keyPath: "transform.scale")
        pulse.values = [1.0, 1.18, 1.0]
        pulse.keyTimes = [0, 0.5, 1]
        pulse.duration = 1.8
        pulse.repeatCount = .infinity
        pulse.timingFunctions = [
            CAMediaTimingFunction(name: .easeInEaseOut),
            CAMediaTimingFunction(name: .easeInEaseOut)
        ]
        iconView.layer.add(pulse, forKey: "pulse")

        let fade = CAKeyframeAnimation(keyPath: "opacity")
        fade.values = [1.0, 0.55, 1.0]
        fade.keyTimes = [0, 0.5, 1]
        fade.duration = 1.8
        fade.repeatCount = .infinity
        iconView.layer.add(fade, forKey: "fade")
    }

    // MARK: - Generation

    private func startGeneration() {
        generationTask = Task {
            do {
                let setID = try await AIService.shared.generateCards(from: fileURL)
                try Task.checkCancellation()

                // Try to fetch full deck details; if this fails the set still exists in the library
                let deck: LibraryModels.DeckSet?
                do {
                    let detail = try await cardService.getSet(setId: setID)
                    try Task.checkCancellation()
                    deck = buildDeckSet(from: detail)
                } catch is CancellationError {
                    return
                } catch {
                    deck = nil
                }

                await MainActor.run {
                    onComplete?(deck)
                }
            } catch is CancellationError {
                // dismissed by user — no action needed
            } catch {
                await MainActor.run { [weak self] in
                    self?.showError(error.localizedDescription)
                }
            }
        }
    }

    private func buildDeckSet(from detail: CardSetDetailAPI) -> LibraryModels.DeckSet {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = formatter.date(from: detail.createdAt)
            ?? ISO8601DateFormatter().date(from: detail.createdAt)
            ?? Date()

        let name = detail.author?.name
        let username = detail.author?.username
        let nameIsEmail = name?.contains("@") == true
        let authorName = username?.isEmpty == false ? username : (nameIsEmail ? nil : name)

        return LibraryModels.DeckSet(
            id: UUID(uuidString: detail.id) ?? UUID(),
            title: detail.name,
            learned: detail.learnedCount,
            total: detail.cardCount,
            addedAt: date,
            colorIndex: abs(detail.id.hashValue) % 4,
            isUserOwned: true,
            authorName: authorName
        )
    }

    // MARK: - Actions

    @objc
    private func cancelTapped() {
        generationTask?.cancel()
        dismiss(animated: true)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: L10n.AIGeneration.errorTitle,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: L10n.Common.ok, style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
}
