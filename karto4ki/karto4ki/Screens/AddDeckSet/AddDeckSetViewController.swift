import UIKit

/// Экран «Добавление набора карточек»: ИИ-загрузка + ручные карточки (без переключателя «по одной / пакетом»).
final class AddDeckSetViewController: UIViewController {

    // MARK: - Dependencies

    private let cardService: CardServiceProtocol
    private let onSetCreated: (() -> Void)?

    // MARK: - UI

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let screenTitleLabel = UILabel()

    private let nameSection = UIView()
    private let nameTitleLabel = UILabel()
    private let nameField = UITextField()

    private let aiSection = UIView()
    private let aiTitleLabel = UILabel()
    private let aiSubtitleLabel = UILabel()
    private let uploadTapArea = UIView()

    private let manualTitleLabel = UILabel()
    private let manualWrapper = UIView()
    private let manualCardsStack = UIStackView()
    private let addAnotherCardButton = UIButton(type: .system)
    private let createSetButton = UIButton(type: .system)

    private lazy var loadingOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        overlay.isHidden = true
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
        ])
        return overlay
    }()

    private let profilePurple = UIColor(red: 0.45, green: 0.40, blue: 0.90, alpha: 1)
    private let glassCorner: CGFloat = 22
    private let questionLimit = 500
    private let answerLimit = 1000

    // MARK: - Init

    init(cardService: CardServiceProtocol, onSetCreated: (() -> Void)? = nil) {
        self.cardService = cardService
        self.onSetCreated = onSetCreated
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
        configureTop()
        configureNameBlock()
        configureAIBlock()
        configureOrSeparator()
        configureManualSection()
        configureCreateButton()
        appendManualCardBlock()
        configureLoadingOverlay()
    }

    private func configureLoadingOverlay() {
        view.addSubview(loadingOverlay)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func configureBackground() {
        let bg = BackgroundView()
        view.addSubview(bg)
        bg.pin(to: view)
        view.sendSubviewToBack(bg)
    }

    private func configureScroll() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Прибиваем к keyboardLayoutGuide — скролл автоматически сжимается при появлении клавиатуры
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 8),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -28),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }

    private func configureTop() {
        screenTitleLabel.text = "Добавление набора карточек"
        screenTitleLabel.font = Fonts.futuraB17
        screenTitleLabel.textColor = .white
        screenTitleLabel.numberOfLines = 0
        screenTitleLabel.translatesAutoresizingMaskIntoConstraints = false

        let row = UIView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(screenTitleLabel)

        NSLayoutConstraint.activate([
            screenTitleLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 2),
            screenTitleLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            screenTitleLabel.topAnchor.constraint(equalTo: row.topAnchor),
            screenTitleLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor),
            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 36)
        ])

        contentStack.addArrangedSubview(row)
        contentStack.setCustomSpacing(18, after: row)
    }

    private func configureNameBlock() {
        wrapGlass(nameSection)
        nameSection.translatesAutoresizingMaskIntoConstraints = false

        nameTitleLabel.text = "Название набора"
        nameTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        nameTitleLabel.textColor = UIColor.white

        nameField.attributedPlaceholder = NSAttributedString(
            string: "Введите название...",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )
        nameField.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        nameField.textColor = .white
        nameField.backgroundColor = .white.withAlphaComponent(0.2)
        nameField.layer.cornerRadius = 16
        nameField.layer.borderWidth = 1
        nameField.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        nameField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 44))
        nameField.leftViewMode = .always
        nameField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 44))
        nameField.rightViewMode = .always
        nameField.setHeight(48)

        let inner = UIStackView(arrangedSubviews: [nameTitleLabel, nameField])
        inner.axis = .vertical
        inner.spacing = 10
        inner.translatesAutoresizingMaskIntoConstraints = false
        nameSection.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: nameSection.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: nameSection.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: nameSection.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: nameSection.bottomAnchor, constant: -16)
        ])

        contentStack.addArrangedSubview(nameSection)
    }

    private func configureAIBlock() {
        wrapGlass(aiSection)
        aiSection.translatesAutoresizingMaskIntoConstraints = false

        aiTitleLabel.text = "Создать с помощью ИИ"
        aiTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        aiTitleLabel.textColor = .white

        aiSubtitleLabel.text = "Загрузите файл, а мы сами создадим карточки на его основе"
        aiSubtitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        aiSubtitleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
        aiSubtitleLabel.numberOfLines = 0

        uploadTapArea.translatesAutoresizingMaskIntoConstraints = false
        uploadTapArea.backgroundColor = .white.withAlphaComponent(0.12)
        uploadTapArea.layer.cornerRadius = 18
        let dash = DashedRoundedBorderView()
        dash.translatesAutoresizingMaskIntoConstraints = false
        uploadTapArea.addSubview(dash)
        dash.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dash.topAnchor.constraint(equalTo: uploadTapArea.topAnchor),
            dash.leadingAnchor.constraint(equalTo: uploadTapArea.leadingAnchor),
            dash.trailingAnchor.constraint(equalTo: uploadTapArea.trailingAnchor),
            dash.bottomAnchor.constraint(equalTo: uploadTapArea.bottomAnchor),
            uploadTapArea.heightAnchor.constraint(greaterThanOrEqualToConstant: 96)
        ])

        let sparkCfg = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
        let spark = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: sparkCfg))
        spark.tintColor = profilePurple
        spark.contentMode = .scaleAspectFit
        spark.translatesAutoresizingMaskIntoConstraints = false
        let sparkWrap = UIView()
        sparkWrap.translatesAutoresizingMaskIntoConstraints = false
        sparkWrap.backgroundColor = .white.withAlphaComponent(0.92)
        sparkWrap.layer.cornerRadius = 22
        sparkWrap.addSubview(spark)
        NSLayoutConstraint.activate([
            sparkWrap.widthAnchor.constraint(equalToConstant: 44),
            sparkWrap.heightAnchor.constraint(equalToConstant: 44),
            spark.centerXAnchor.constraint(equalTo: sparkWrap.centerXAnchor),
            spark.centerYAnchor.constraint(equalTo: sparkWrap.centerYAnchor)
        ])

        let uploadTitle = UILabel()
        uploadTitle.text = "Загрузите файл"
        uploadTitle.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        uploadTitle.textColor = .white

        let uploadHint = UILabel()
        uploadHint.text = "PDF, DOCX, TXT или изображение до 20 МБ"
        uploadHint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        uploadHint.textColor = UIColor.white.withAlphaComponent(0.72)
        uploadHint.numberOfLines = 0

        let chevCfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        let chevron = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: chevCfg))
        chevron.tintColor = .white.withAlphaComponent(0.85)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let textCol = UIStackView(arrangedSubviews: [uploadTitle, uploadHint])
        textCol.axis = .vertical
        textCol.spacing = 4
        textCol.alignment = .leading

        let uploadRow = UIStackView(arrangedSubviews: [sparkWrap, textCol, chevron])
        uploadRow.axis = .horizontal
        uploadRow.alignment = .center
        uploadRow.spacing = 12
        uploadRow.translatesAutoresizingMaskIntoConstraints = false
        uploadTapArea.addSubview(uploadRow)
        NSLayoutConstraint.activate([
            uploadRow.topAnchor.constraint(equalTo: uploadTapArea.topAnchor, constant: 14),
            uploadRow.leadingAnchor.constraint(equalTo: uploadTapArea.leadingAnchor, constant: 14),
            uploadRow.trailingAnchor.constraint(equalTo: uploadTapArea.trailingAnchor, constant: -14),
            uploadRow.bottomAnchor.constraint(equalTo: uploadTapArea.bottomAnchor, constant: -14)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(uploadTapped))
        uploadTapArea.addGestureRecognizer(tap)
        uploadTapArea.isUserInteractionEnabled = true

        let inner = UIStackView(arrangedSubviews: [aiTitleLabel, aiSubtitleLabel, uploadTapArea])
        inner.axis = .vertical
        inner.spacing = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        aiSection.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: aiSection.topAnchor, constant: 16),
            inner.leadingAnchor.constraint(equalTo: aiSection.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: aiSection.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: aiSection.bottomAnchor, constant: -16)
        ])

        contentStack.addArrangedSubview(aiSection)
    }

    private func configureOrSeparator() {
        let lineL = UIView()
        lineL.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        lineL.translatesAutoresizingMaskIntoConstraints = false
        lineL.setHeight(1)

        let lineR = UIView()
        lineR.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        lineR.translatesAutoresizingMaskIntoConstraints = false
        lineR.setHeight(1)

        let mid = UILabel()
        mid.text = "или добавьте вручную"
        mid.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        mid.textColor = UIColor.white.withAlphaComponent(0.78)
        mid.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [lineL, mid, lineR])
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .center
        row.distribution = .fill
        lineL.widthAnchor.constraint(equalTo: lineR.widthAnchor).isActive = true

        contentStack.addArrangedSubview(row)
    }

    private func configureManualSection() {
        manualTitleLabel.text = "Добавить карточки вручную"
        manualTitleLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        manualTitleLabel.textColor = .white
        contentStack.addArrangedSubview(manualTitleLabel)

        wrapGlass(manualWrapper)
        manualWrapper.translatesAutoresizingMaskIntoConstraints = false

        manualCardsStack.axis = .vertical
        manualCardsStack.spacing = 14

        var cfg = UIButton.Configuration.plain()
        cfg.image = UIImage(systemName: "plus.circle.fill")
        cfg.title = "Добавить карточку"
        cfg.imagePlacement = .leading
        cfg.imagePadding = 8
        cfg.baseForegroundColor = .white
        cfg.background.backgroundColor = .white.withAlphaComponent(0.3)
        cfg.background.cornerRadius = 16
        cfg.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
        cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var o = incoming
            o.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            return o
        }
        addAnotherCardButton.configuration = cfg
        addAnotherCardButton.addTarget(self, action: #selector(addCardBlockTapped), for: .touchUpInside)

        let inner = UIStackView(arrangedSubviews: [manualCardsStack, addAnotherCardButton])
        inner.axis = .vertical
        inner.spacing = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        manualWrapper.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: manualWrapper.topAnchor, constant: 14),
            inner.leadingAnchor.constraint(equalTo: manualWrapper.leadingAnchor, constant: 14),
            inner.trailingAnchor.constraint(equalTo: manualWrapper.trailingAnchor, constant: -14),
            inner.bottomAnchor.constraint(equalTo: manualWrapper.bottomAnchor, constant: -14)
        ])
        contentStack.addArrangedSubview(manualWrapper)
    }

    private func configureCreateButton() {
        createSetButton.setTitle("Создать набор", for: .normal)
        createSetButton.setTitleColor(.white, for: .normal)
        createSetButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        createSetButton.backgroundColor = profilePurple
        createSetButton.layer.cornerRadius = glassCorner
        createSetButton.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        createSetButton.addTarget(self, action: #selector(createSetTapped), for: .touchUpInside)
        createSetButton.setHeight(54)
        contentStack.addArrangedSubview(createSetButton)
    }

    private func appendManualCardBlock() {
        if !manualCardsStack.arrangedSubviews.isEmpty {
            let sep = UIView()
            sep.backgroundColor = UIColor.white.withAlphaComponent(0.28)
            sep.translatesAutoresizingMaskIntoConstraints = false
            sep.setHeight(1)
            manualCardsStack.addArrangedSubview(sep)
        }
        let block = ManualCardEntryView(questionLimit: questionLimit, answerLimit: answerLimit)
        manualCardsStack.addArrangedSubview(block)
    }

    private func wrapGlass(_ v: UIView) {
        v.backgroundColor = .white.withAlphaComponent(0.26)
        v.layer.cornerRadius = glassCorner
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.white.withAlphaComponent(0.45).cgColor
        v.clipsToBounds = true
    }

    @objc
    private func uploadTapped() {
        let a = UIAlertController(
            title: nil,
            message: "Загрузка файлов и генерация карточек появятся после подключения API.",
            preferredStyle: .alert
        )
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }

    @objc
    private func addCardBlockTapped() {
        appendManualCardBlock()
    }

    @objc
    private func createSetTapped() {
        let name = (nameField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            let a = UIAlertController(title: nil, message: "Введите название набора.", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return
        }

        // Собираем заполненные карточки
        let cards = collectCards()
        guard !cards.isEmpty else {
            let a = UIAlertController(title: nil, message: "Добавьте хотя бы одну карточку.", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default))
            present(a, animated: true)
            return
        }

        view.endEditing(true)
        loadingOverlay.isHidden = false
        createSetButton.isEnabled = false

        Task {
            do {
                // 1. Создаём набор
                let setRequest = CreateCardSetRequestAPI(name: name, description: nil, isPublic: false)
                let createdSet = try await cardService.createSet(setRequest, idempotencyKey: UUID().uuidString)

                // 2. Создаём карточки последовательно
                for card in cards {
                    let cardRequest = CreateCardRequestAPI(front: card.front, back: card.back, imageUrl: nil)
                    _ = try await cardService.createCard(
                        setId: createdSet.id,
                        request: cardRequest,
                        idempotencyKey: UUID().uuidString
                    )
                }

                await MainActor.run {
                    self.loadingOverlay.isHidden = true
                    self.createSetButton.isEnabled = true
                    self.onSetCreated?()
                }
            } catch {
                await MainActor.run {
                    self.loadingOverlay.isHidden = true
                    self.createSetButton.isEnabled = true
                    let a = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось создать набор. Попробуйте ещё раз.",
                        preferredStyle: .alert
                    )
                    a.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(a, animated: true)
                }
            }
        }
    }

    /// Собирает карточки из всех `ManualCardEntryView` со заполненным вопросом и ответом.
    private func collectCards() -> [(front: String, back: String)] {
        manualCardsStack.arrangedSubviews
            .compactMap { $0 as? ManualCardEntryView }
            .compactMap { $0.cardPair }
    }
}

// MARK: - Ручная карточка

final class ManualCardEntryView: UIView, UITextViewDelegate {

    private let questionLimit: Int
    private let answerLimit: Int

    private let innerStack = UIStackView()
    private let questionTitle = UILabel()
    private let questionView = UITextView()
    private let questionCounter = UILabel()
    private let answerTitle = UILabel()
    private let answerView = UITextView()
    private let answerCounter = UILabel()

    init(questionLimit: Int, answerLimit: Int) {
        self.questionLimit = questionLimit
        self.answerLimit = answerLimit
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        innerStack.axis = .vertical
        innerStack.spacing = 8
        innerStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(innerStack)

        func caption(_ label: UILabel, text: String) {
            label.text = text
            label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            label.textColor = UIColor.white
        }
        caption(questionTitle, text: "Вопрос")
        caption(answerTitle, text: "Ответ")

        styleField(questionView, placeholder: "Введите вопрос...")
        styleField(answerView, placeholder: "Введите ответ...")
        questionView.delegate = self
        answerView.delegate = self
        questionView.tag = 0
        answerView.tag = 1

        questionCounter.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        questionCounter.textColor = UIColor.white.withAlphaComponent(0.6)
        answerCounter.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        answerCounter.textColor = UIColor.white.withAlphaComponent(0.6)
        updateCounters()

        innerStack.addArrangedSubview(questionTitle)
        innerStack.addArrangedSubview(questionView)
        innerStack.addArrangedSubview(questionCounter)
        innerStack.addArrangedSubview(answerTitle)
        innerStack.addArrangedSubview(answerView)
        innerStack.addArrangedSubview(answerCounter)

        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            innerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            innerStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            innerStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14),
            questionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88),
            answerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 88)
        ])
    }

    private func styleField(_ tv: UITextView, placeholder: String) {
        tv.backgroundColor = .white.withAlphaComponent(0.18)
        tv.layer.cornerRadius = 14
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        tv.textContainer.lineFragmentPadding = 0
        tv.isScrollEnabled = false
        tv.text = ""
        tv.addPlaceholderIfNeeded(placeholder)
    }

    /// Возвращает пару (вопрос, ответ) если оба поля заполнены.
    var cardPair: (front: String, back: String)? {
        let front = (questionView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let back  = (answerView.text  ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !front.isEmpty, !back.isEmpty else { return nil }
        return (front, back)
    }

    private func updateCounters() {
        let qLen = (questionView.text ?? "").count
        let aLen = (answerView.text ?? "").count
        questionCounter.text = "\(min(qLen, questionLimit))/\(questionLimit)"
        answerCounter.text = "\(min(aLen, answerLimit))/\(answerLimit)"
    }

    func textViewDidChange(_ textView: UITextView) {
        let limit = textView.tag == 0 ? questionLimit : answerLimit
        if textView.text.count > limit {
            textView.text = String(textView.text.prefix(limit))
        }
        if (textView.text ?? "").isEmpty {
            let ph = textView.tag == 0 ? "Введите вопрос..." : "Введите ответ..."
            textView.addPlaceholderIfNeeded(ph)
        } else {
            textView.removePlaceholderIfNeeded()
        }
        updateCounters()
    }
}

// MARK: - Пунктирная рамка

private final class DashedRoundedBorderView: UIView {

    private let shape = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        shape.strokeColor = UIColor.white.withAlphaComponent(0.65).cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.lineWidth = 1.5
        shape.lineDashPattern = [6, 4]
        layer.addSublayer(shape)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 0.75, dy: 0.75), cornerRadius: 17)
        shape.path = path.cgPath
        shape.frame = bounds
    }
}

// MARK: - Placeholder для UITextView

private extension UITextView {

    private static var placeholderTag: Int { 90909 }

    func addPlaceholderIfNeeded(_ text: String) {
        guard subviews.first(where: { $0.tag == Self.placeholderTag }) == nil else { return }
        let lb = UILabel()
        lb.tag = Self.placeholderTag
        lb.text = text
        lb.font = self.font
        lb.textColor = UIColor.white.withAlphaComponent(0.7)
        lb.numberOfLines = 0
        lb.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lb)
        NSLayoutConstraint.activate([
            lb.topAnchor.constraint(equalTo: topAnchor, constant: textContainerInset.top + 2),
            lb.leadingAnchor.constraint(equalTo: leadingAnchor, constant: textContainerInset.left + 5),
            lb.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12)
        ])
    }

    func removePlaceholderIfNeeded() {
        subviews.first { $0.tag == Self.placeholderTag }?.removeFromSuperview()
    }
}
